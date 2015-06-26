require "shoulda-context"
require "minitest/autorun"
require "incodesert"

class TestIncodesert < MiniTest::Test
  context 'With C-style comments' do
    setup do
      @destination = <<EOF
  this_should_stay_the_same();

  // <<< token
  
  code_to_be_replaced();
  
  // >>> token
  
  also_should_stay_same();

  // <<< token with spaces

  // something else to be replaced
  
  // >>> token with spaces
  
  bringing_it_home();
EOF

    end

    should 'leave untouched when fed empty source' do
      doc = Incodesert::Documents.new("", @destination)
      doc.perform_insertions!
      assert_equal @destination, doc.destination
      assert_equal "", doc.extractions
      assert_equal "", doc.warnings
    end

    should 'be a new object when fed empty source' do
      doc = Incodesert::Documents.new("", @destination)
      doc.perform_insertions!
      refute @destination.equal? doc.destination
      assert_equal "", doc.extractions
      assert_equal "", doc.warnings
    end
    
    should 'leave untouched and warn when fed source with unclosed tokens' do
      source = <<EOF
  // <<< garbage
  
  // we should never see this
  
  // >>> rubbish
EOF

      warnings = <<EOF
In source: open and close blocks do not match!!
Opened with garbage
Closed with rubbish
EOF

      doc = Incodesert::Documents.new(source, @destination)
      doc.perform_insertions!
      assert_equal @destination, doc.destination
      assert_equal "", doc.extractions
      assert_equal warnings, doc.warnings
    end    
    
    should 'leave untouched when fed non-matching source' do
      source = <<EOF
  // <<< garbage
  
  // we should never see this
  
  // >>> garbage
EOF

      doc = Incodesert::Documents.new(source, @destination)
      doc.perform_insertions!
      assert_equal @destination, doc.destination
      assert_equal "", doc.extractions
    end    
    
    should 'replace simple token with matching source and no warnings' do
      source = <<EOF
  // <<< token
  
  replaced_function();
  
  // >>> token
EOF

      result = <<EOF
  this_should_stay_the_same();

  // <<< token
  
  replaced_function();
  
  // >>> token
  
  also_should_stay_same();

  // <<< token with spaces

  // something else to be replaced
  
  // >>> token with spaces
  
  bringing_it_home();
EOF

      extractions = <<EOF
  // <<< token
  
  code_to_be_replaced();
  
  // >>> token
EOF

      doc = Incodesert::Documents.new(source, @destination)
      doc.no_warn = true
      doc.perform_insertions!
      assert_equal result, doc.destination
      assert_equal extractions, doc.extractions
      assert_equal "", doc.warnings
    end    
    
    should 'replace simple token with matching source with trailing whitespaceand no warnings' do
    
      # You can't see it, but the two tokens here in the source have varying amounts of
      # trailing whitespace.  It should match anyway.
      source = <<EOF
  // <<< token 
  
  replaced_function();
  
  // >>> token   
EOF

      result = <<EOF
  this_should_stay_the_same();

  // <<< token 
  
  replaced_function();
  
  // >>> token   
  
  also_should_stay_same();

  // <<< token with spaces

  // something else to be replaced
  
  // >>> token with spaces
  
  bringing_it_home();
EOF

      extractions = <<EOF
  // <<< token
  
  code_to_be_replaced();
  
  // >>> token
EOF

      doc = Incodesert::Documents.new(source, @destination)
      doc.no_warn = true
      doc.perform_insertions!
      assert_equal result, doc.destination
      assert_equal extractions, doc.extractions
      assert_equal "", doc.warnings
    end    
    
    should 'replace simple token with matching source and with warnings' do
      source = <<EOF
  // <<< token
  
  replaced_function();
  
  // >>> token
EOF

      result = <<EOF
  this_should_stay_the_same();

  // <<< token
  //
  // WARNING!!! This code auto-inserted by incodesert
  // Do not edit this block!
  
  replaced_function();
  
  // >>> token
  
  also_should_stay_same();

  // <<< token with spaces

  // something else to be replaced
  
  // >>> token with spaces
  
  bringing_it_home();
EOF

      extractions = <<EOF
  // <<< token
  
  code_to_be_replaced();
  
  // >>> token
EOF

      doc = Incodesert::Documents.new(source, @destination)
      doc.perform_insertions!
      assert_equal result, doc.destination
      assert_equal extractions, doc.extractions
      assert_equal "", doc.warnings
    end    
    
    should 'replace multi-word token with matching source and no warnings' do
      source = <<EOF
  // <<< token with spaces

  // something else that has been replaced
  
  // >>> token with spaces
EOF

      result = <<EOF
  this_should_stay_the_same();

  // <<< token
  
  code_to_be_replaced();
  
  // >>> token
  
  also_should_stay_same();

  // <<< token with spaces

  // something else that has been replaced
  
  // >>> token with spaces
  
  bringing_it_home();
EOF

      extractions = <<EOF
  // <<< token with spaces

  // something else to be replaced
  
  // >>> token with spaces
EOF

      doc = Incodesert::Documents.new(source, @destination)
      doc.no_warn = true
      doc.perform_insertions!
      assert_equal result, doc.destination
      assert_equal extractions, doc.extractions
      assert_equal "", doc.warnings
    end    
    
    should 'replace all segments with matching source and no warnings' do
      source = <<EOF
  // <<< token
  
  replaced_function();
  
  // >>> token
  
  // <<< token with spaces

  // something else that has been replaced
  
  // >>> token with spaces
EOF

      result = <<EOF
  this_should_stay_the_same();

  // <<< token
  
  replaced_function();
  
  // >>> token
  
  also_should_stay_same();

  // <<< token with spaces

  // something else that has been replaced
  
  // >>> token with spaces
  
  bringing_it_home();
EOF

      extractions = <<EOF
  // <<< token
  
  code_to_be_replaced();
  
  // >>> token
  // <<< token with spaces

  // something else to be replaced
  
  // >>> token with spaces
EOF

      doc = Incodesert::Documents.new(source, @destination)
      doc.no_warn = true
      doc.perform_insertions!
      assert_equal result, doc.destination
      assert_equal extractions, doc.extractions
      assert_equal "", doc.warnings
    end    
    
  end


  context 'With script-style comments' do
    setup do
      @destination = <<EOF
  this_should_stay_the_same();

  # <<< token
  
  code_to_be_replaced();
  
  # >>> token
  
  also_should_stay_same();

  # <<< token with spaces

  # something else to be replaced
  
  # >>> token with spaces
  
  bringing_it_home();
EOF

    end

    should 'leave untouched when fed empty source' do
      doc = Incodesert::Documents.new("", @destination)
      doc.perform_insertions!
      assert_equal @destination, doc.destination
      assert_equal "", doc.extractions
      assert_equal "", doc.warnings
    end

    should 'be a new object when fed empty source' do
      doc = Incodesert::Documents.new("", @destination)
      doc.perform_insertions!
      refute @destination.equal? doc.destination
      assert_equal "", doc.extractions
      assert_equal "", doc.warnings
    end
    
    should 'leave untouched and warn when fed source with unclosed tokens' do
      source = <<EOF
  # <<< garbage
  
  # we should never see this
  
  # >>> rubbish
EOF

      warnings = <<EOF
In source: open and close blocks do not match!!
Opened with garbage
Closed with rubbish
EOF

      doc = Incodesert::Documents.new(source, @destination)
      doc.perform_insertions!
      assert_equal @destination, doc.destination
      assert_equal "", doc.extractions
      assert_equal warnings, doc.warnings
    end    
    
    should 'leave untouched when fed non-matching source' do
      source = <<EOF
  # <<< garbage
  
  # we should never see this
  
  # >>> garbage
EOF

      doc = Incodesert::Documents.new(source, @destination)
      doc.perform_insertions!
      assert_equal @destination, doc.destination
      assert_equal "", doc.extractions
    end    
    
    should 'replace simple token with matching source and no warnings' do
      source = <<EOF
  # <<< token
  
  replaced_function();
  
  # >>> token
EOF

      result = <<EOF
  this_should_stay_the_same();

  # <<< token
  
  replaced_function();
  
  # >>> token
  
  also_should_stay_same();

  # <<< token with spaces

  # something else to be replaced
  
  # >>> token with spaces
  
  bringing_it_home();
EOF

      extractions = <<EOF
  # <<< token
  
  code_to_be_replaced();
  
  # >>> token
EOF

      doc = Incodesert::Documents.new(source, @destination)
      doc.no_warn = true
      doc.perform_insertions!
      assert_equal result, doc.destination
      assert_equal extractions, doc.extractions
      assert_equal "", doc.warnings
    end    
    
    should 'replace simple token with matching source and with warnings' do
      source = <<EOF
  # <<< token
  
  replaced_function();
  
  # >>> token
EOF

      result = <<EOF
  this_should_stay_the_same();

  # <<< token
  #
  # WARNING!!! This code auto-inserted by incodesert
  # Do not edit this block!
  
  replaced_function();
  
  # >>> token
  
  also_should_stay_same();

  # <<< token with spaces

  # something else to be replaced
  
  # >>> token with spaces
  
  bringing_it_home();
EOF

      extractions = <<EOF
  # <<< token
  
  code_to_be_replaced();
  
  # >>> token
EOF

      doc = Incodesert::Documents.new(source, @destination)
      doc.perform_insertions!
      assert_equal result, doc.destination
      assert_equal extractions, doc.extractions
      assert_equal "", doc.warnings
    end    
    
    should 'replace multi-word token with matching source and no warnings' do
      source = <<EOF
  # <<< token with spaces

  # something else that has been replaced
  
  # >>> token with spaces
EOF

      result = <<EOF
  this_should_stay_the_same();

  # <<< token
  
  code_to_be_replaced();
  
  # >>> token
  
  also_should_stay_same();

  # <<< token with spaces

  # something else that has been replaced
  
  # >>> token with spaces
  
  bringing_it_home();
EOF

      extractions = <<EOF
  # <<< token with spaces

  # something else to be replaced
  
  # >>> token with spaces
EOF

      doc = Incodesert::Documents.new(source, @destination)
      doc.no_warn = true
      doc.perform_insertions!
      assert_equal result, doc.destination
      assert_equal extractions, doc.extractions
      assert_equal "", doc.warnings
    end    
    
    should 'replace all segments with matching source and no warnings' do
      source = <<EOF
  # <<< token
  
  replaced_function();
  
  # >>> token
  
  # <<< token with spaces

  # something else that has been replaced
  
  # >>> token with spaces
EOF

      result = <<EOF
  this_should_stay_the_same();

  # <<< token
  
  replaced_function();
  
  # >>> token
  
  also_should_stay_same();

  # <<< token with spaces

  # something else that has been replaced
  
  # >>> token with spaces
  
  bringing_it_home();
EOF

      extractions = <<EOF
  # <<< token
  
  code_to_be_replaced();
  
  # >>> token
  # <<< token with spaces

  # something else to be replaced
  
  # >>> token with spaces
EOF

      doc = Incodesert::Documents.new(source, @destination)
      doc.no_warn = true
      doc.perform_insertions!
      assert_equal result, doc.destination
      assert_equal extractions, doc.extractions
      assert_equal "", doc.warnings
    end    
    
  end
  
  
  context 'With unmatched C-style comments' do
    setup do
      @destination = <<EOF
  this_should_stay_the_same();

  // <<< token
  
  code_to_be_replaced();
  
  // >>> token that does't match
EOF

    end

    should 'leave warn' do
      warnings = <<EOF
In Destination: open and close blocks do not match!!
Opened with token
Closed with token that does't match
EOF

      doc = Incodesert::Documents.new("", @destination)
      doc.perform_insertions!
      assert_equal @destination, doc.destination
      assert_equal "", doc.extractions
      assert_equal warnings, doc.warnings
    end
  end



  context 'With unmatched script-style comments' do
    setup do
      @destination = <<EOF
  this_should_stay_the_same();

  # <<< token
  
  code_to_be_replaced();
  
  # >>> token that does't match
EOF

    end

    should 'leave warn' do
      warnings = <<EOF
In Destination: open and close blocks do not match!!
Opened with token
Closed with token that does't match
EOF

      doc = Incodesert::Documents.new("", @destination)
      doc.perform_insertions!
      assert_equal @destination, doc.destination
      assert_equal "", doc.extractions
      assert_equal warnings, doc.warnings
    end
  end
  
  context 'With C-style comments and trailing whitespace' do
    setup do
      # You can't see it, but there is trailing whitespace at the end of each of the 
      # tokens in this setup, and different amounts of whitespace at that.
      # Principle of least surprise tells us that if you can't see something
      # (unseen whitespace), it shouldn't break how you expect the software to behave.
    
      @destination = <<EOF
  this_should_stay_the_same();

  // <<< token with trailing whitespace      
  
  code_to_be_replaced();
  
  // >>> token with trailing whitespace  
  
  also_should_stay_same();
EOF
    end
    
    should 'replace token with trailing whitespace with matching source and no warnings' do
      source = <<EOF
  // <<< token with trailing whitespace
  
  replaced_function();
  
  // >>> token with trailing whitespace
EOF
      result = <<EOF
  this_should_stay_the_same();

  // <<< token with trailing whitespace
  
  replaced_function();
  
  // >>> token with trailing whitespace
  
  also_should_stay_same();
EOF

      extractions = <<EOF
  // <<< token with trailing whitespace      
  
  code_to_be_replaced();
  
  // >>> token with trailing whitespace  
EOF

      doc = Incodesert::Documents.new(source, @destination)
      doc.no_warn = true
      doc.perform_insertions!
      assert_equal result, doc.destination
      assert_equal extractions, doc.extractions
      assert_equal "", doc.warnings
    end    
  end
    
end

