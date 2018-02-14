require 'spec_helper_integration'

describe RedirectUriValidator do
  subject do
    FactoryBot.create(:application)
  end

  it 'is valid when the uri is a uri' do
    subject.redirect_uri = 'https://example.com/callback'
    expect(subject).to be_valid
  end

  it 'is valid when the uri has a query parameter' do
    subject.redirect_uri = 'https://example.com/abcd?xyz=123'
    expect(subject).to be_valid
  end

  it 'accepts native redirect uri' do
    subject.redirect_uri = 'urn:ietf:wg:oauth:2.0:oob'
    expect(subject).to be_valid
  end

  it 'rejects if test uri is disabled' do
    allow(RedirectUriValidator).to receive(:native_redirect_uri).and_return(nil)
    subject.redirect_uri = 'urn:some:test'
    expect(subject).not_to be_valid
  end

  it 'is invalid when the uri is not a uri' do
    subject.redirect_uri = ']'
    expect(subject).not_to be_valid
    expect(subject.errors[:redirect_uri].first).to eq('must be a valid URI.')
  end

  it 'is invalid when the uri is relative' do
    subject.redirect_uri = '/abcd'
    expect(subject).not_to be_valid
    expect(subject.errors[:redirect_uri].first).to eq('must be an absolute URI.')
  end

  it 'is invalid when the uri has a fragment' do
    subject.redirect_uri = 'https://example.com/abcd#xyz'
    expect(subject).not_to be_valid
    expect(subject.errors[:redirect_uri].first).to eq('cannot contain a fragment.')
  end

  context 'force secured uri' do
    it 'accepts an valid uri' do
      subject.redirect_uri = 'https://example.com/callback'
      expect(subject).to be_valid
    end

    it 'accepts native redirect uri' do
      subject.redirect_uri = 'urn:ietf:wg:oauth:2.0:oob'
      expect(subject).to be_valid
    end

    it 'accepts app redirect uri' do
      subject.redirect_uri = 'some-awesome-app://oauth/callback'
      expect(subject).to be_valid
    end

    it 'invalidates the uri when the uri does uses javascript:' do
      subject.redirect_uri = 'javascript://%0aalert%28document.cookie%29//'

      expect(subject).not_to be_valid
      error = subject.errors[:redirect_uri].first
      expect(error).to eq('must be an HTTPS/SSL URI.')
    end

    it 'accepts a non secured protocol when disabled' do
      subject.redirect_uri = 'http://example.com/callback'
      allow(Doorkeeper.configuration).to receive(
                                             :force_ssl_in_redirect_uri
                                         ).and_return(false)
      expect(subject).to be_valid
    end

    it 'accepts a non secured protocol when conditional option defined' do
      Doorkeeper.configure do
        orm DOORKEEPER_ORM
        force_ssl_in_redirect_uri { |uri| uri.host != 'localhost' }
      end

      application = FactoryBot.build(:application, redirect_uri: 'http://localhost/callback')
      expect(application).to be_valid

      application = FactoryBot.build(:application, redirect_uri: 'http://localhost2/callback')
      expect(application).not_to be_valid
    end

    it 'invalidates the uri when the uri does not use a secure protocol' do
      subject.redirect_uri = 'http://example.com/callback'

      expect(subject).not_to be_valid
      error = subject.errors[:redirect_uri].first
      expect(error).to eq('must be an HTTPS/SSL URI.')
    end
  end
end
