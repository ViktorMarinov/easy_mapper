require 'spec_helper'

RSpec.describe 'EasyMapper::Query' do
  let(:user_model) do
    Class.new do
      include EasyMapper::Model

      attributes :first_name, :last_name, :age
    end
  end

  describe '.new' do
    it 'creates query for the given model' do
      query = user_model.objects
      expect(query.model).to eq user_model
    end
  end
end
