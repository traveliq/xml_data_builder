$LOAD_PATH.unshift(File.join(File.dirname(__FILE__), '..', 'lib'))
require 'xml_data_builder'
require 'builder'
require 'active_support/inflector'

describe XmlDataBuilder do

  it "should render an empty document" do
    data = {}
    xml = XmlDataBuilder.new(data, :indent => 2)
    xml.document.strip.should == '<?xml version="1.0" encoding="UTF-8"?>'
  end

  it "should render integers" do
    data = {:my_number => 1}
    xml = XmlDataBuilder.new(data, :indent => 2)
    xml.document.strip.should ==
'<?xml version="1.0" encoding="UTF-8"?>
<my_number>1</my_number>'
  end

  it "should render floats" do
    data = {:pi => 3.14}
    xml = XmlDataBuilder.new(data, :indent => 2)
    xml.document.strip.should ==
'<?xml version="1.0" encoding="UTF-8"?>
<pi>3.14</pi>'
  end

  it "should render symbold" do
    data = {:symbol => 'prince'}
    xml = XmlDataBuilder.new(data, :indent => 2)
    xml.document.strip.should ==
'<?xml version="1.0" encoding="UTF-8"?>
<symbol>prince</symbol>'
  end

  it "should render strings" do
    data = {:my_string => 'boring!'}
    xml = XmlDataBuilder.new(data, :indent => 2)
    xml.document.strip.should ==
'<?xml version="1.0" encoding="UTF-8"?>
<my_string>boring!</my_string>'
  end

  it "should render CDATA" do
    data = {:my_cdata => XmlDataBuilder::CDATA.new('<Oh my!/>')}
    xml = XmlDataBuilder.new(data, :indent => 2)
    xml.document.strip.should ==
'<?xml version="1.0" encoding="UTF-8"?>
<my_cdata>
  <![CDATA[<Oh my!/>]]>
</my_cdata>'
  end

  it "should render nested data" do
    data = {:my_data => {:one => 1, :two => 2}}
    xml = XmlDataBuilder.new(data, :indent => 2)
    xml.document.strip.split("\n").sort.should ==
'<?xml version="1.0" encoding="UTF-8"?>
<my_data>
  <two>2</two>
  <one>1</one>
</my_data>'.split("\n").sort
  end

  it "should render arrays" do
    data = {:items => ['bread', 'butter']}
    xml = XmlDataBuilder.new(data, :indent => 2)
    xml.document.strip.should ==
'<?xml version="1.0" encoding="UTF-8"?>
<items>
  <item>bread</item>
  <item>butter</item>
</items>'
  end

  it "should render complex data" do
    data = {:nest => {:inner_elements => [{:one => 1.0}, {:two => 'two', :wtf => XmlDataBuilder::CDATA.new(42)}]}}
    xml = XmlDataBuilder.new(data, :indent => 2)
    xml.document.strip.split("\n").sort.should ==
'<?xml version="1.0" encoding="UTF-8"?>
<nest>
  <inner_elements>
    <inner_element>
      <one>1.0</one>
    </inner_element>
    <inner_element>
      <two>two</two>
      <wtf>
        <![CDATA[42]]>
      </wtf>
    </inner_element>
  </inner_elements>
</nest>'.split("\n").sort
  end

  it "should not except arrays" do
    data = [:illegal]
    lambda{ XmlDataBuilder.new(data, :indent => 2).document }.should raise_error ArgumentError
  end

  it "should not except nested arrays within the structure" do
    data = {:illegal => [[:me]]}
    lambda{ XmlDataBuilder.new(data, :indent => 2).document }.should raise_error ArgumentError
  end

end
