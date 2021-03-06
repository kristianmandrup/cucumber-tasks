require 'require-me'
Folder.require_spec 'spec_helper', __FILE__

module Hello
  describe Basic do
    context "empty basic" do
      let(:basic)  { Hello::Basic.new }
    
      describe "#basic" do      
        it "should not have a name" do
          basic.name.should be_nil
        end      
      end 
    end
  
    context "named basic" do
      let(:named)  { Hello::Basic.new 'blip' }
      it "should have a name 'blip' " do
        named.name.should be == "blip"
      end      
    end
  end
end