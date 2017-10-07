require 'spec_helper'
describe 'ut_backup' do

  context 'with defaults for all parameters' do
    it { should contain_class('ut_backup') }
  end
end
