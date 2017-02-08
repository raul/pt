require 'spec_helper'

 RSpec.describe 'First Run', :type => :aruba do
   let(:file) { 'file.txt' }
   let(:content) { 'Hello World' }

   before(:each) { write_file file, content }

   it { expect(read(file)).to eq [content] }
 end

 describe Pt do
   let(:subject) { describe_class.new }
 end
