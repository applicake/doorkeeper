require 'spec_helper'
require 'active_support/core_ext/module/delegation'
require 'active_support/core_ext/object/blank'
require 'doorkeeper/oauth/scopes'
require 'doorkeeper/models/concerns/scopes'

describe 'Doorkeeper::Models::Scopes' do
  subject do
    Class.new(Hash) do
      include Doorkeeper::Models::Scopes
    end.new
  end

  before do
    subject[:scopes] = 'public admin'
  end

  describe :scopes do
    it 'is a `Scopes` class' do
      expect(subject.scopes).to be_a(Doorkeeper::OAuth::Scopes)
    end

    it 'includes scopes' do
      expect(subject.scopes).to include('public')
    end

    it 'writes scopes as string' do
      subject.scopes = 'read write'
      expect(subject.scopes).to include('read')
    end

    it 'writes scopes as array' do
      subject.scopes = %w(read write)
      expect(subject.scopes).to include('read')

      subject.scopes = [:foo, :bar]
      expect(subject.scopes).to include('foo')
    end

  end

  describe :scopes_string do
    it 'is a `Scopes` class' do
      expect(subject.scopes_string).to eq('public admin')
    end
  end

  describe :includes_scope? do
    it 'should return true if at least one scope is included' do
      expect(subject.includes_scope?('public', 'private')).to be true
    end

    it 'should return false if no scopes are included' do
      expect(subject.includes_scope?('teacher', 'student')).to be false
    end
  end
end
