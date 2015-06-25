require "shoulda-context"
require "minitest/autorun"
require "incodesert"
require "fileutils"

class TestIncodesert < MiniTest::Test
  context 'With a C-style comments file' do
    setup do
      if Dir.exist?("test/tmp")
        FileUtils.rm_rf Dir.glob("test/tmp/*"), secure: true
      else
        Dir.mkdir("test/tmp")
      end
      
      FileUtils.cp("test/files/destination.cpp", "test/tmp/destination.cpp")
    end
    
    should 'spew to stderr and not modify file when there are mismatched tokens' do
      stdout = `incodesert test/files/source-mismatched-tokens.cpp test/tmp/destination.cpp test/tmp/extractions.cpp 2>&1`
      
      expected_spewage = <<EOF
In source: open and close blocks do not match!!
Opened with garbage
Closed with rubbish
EOF

      # Expect the destination to be unmodified
      expected_destination = File.read("test/files/destination.cpp")
      new_destination = File.read("test/tmp/destination.cpp")
      
      extractions = File.read("test/tmp/extractions.cpp")
      
      assert_equal expected_destination, new_destination
      assert_equal "", extractions
      assert_equal expected_spewage, stdout
    end
    
    should 'replace the first block exactly with --no-warn' do
      stdout = `incodesert --no-warn test/files/source-replace-first.cpp test/tmp/destination.cpp 2>&1`
      

      # Expect the destination to be unmodified
      expected_destination = File.read("test/files/expected-replace-first-nowarn.cpp")
      new_destination = File.read("test/tmp/destination.cpp")
            
      assert_equal expected_destination, new_destination
      assert_equal "", stdout.chomp
    end

    should 'replace the first block with warning comments' do
      stdout = `incodesert test/files/source-replace-first.cpp test/tmp/destination.cpp 2>&1`
      

      # Expect the destination to be unmodified
      expected_destination = File.read("test/files/expected-replace-first.cpp")
      new_destination = File.read("test/tmp/destination.cpp")
            
      assert_equal expected_destination, new_destination
      assert_equal "", stdout.chomp
    end

    should 'extract the first block' do
      `incodesert test/files/source-replace-first.cpp test/tmp/destination.cpp test/tmp/extractions.cpp 2>&1`
      

      # Expect the destination to be unmodified
      expected_extractions = File.read("test/files/expected-extractions-first.cpp")
      new_extractions = File.read("test/tmp/extractions.cpp")
            
      assert_equal expected_extractions, new_extractions
    end

    should 'restore a file to original condition by reinserting extractions' do
      `incodesert test/files/source-replace-first.cpp test/tmp/destination.cpp test/tmp/extractions.cpp 2>&1`
      
      stdout = `incodesert --no-warn test/tmp/extractions.cpp test/tmp/destination.cpp 2>&1`

      # Expect the destination to be unmodified
      expected_extractions = File.read("test/files/expected-extractions-first.cpp")
      new_extractions = File.read("test/tmp/extractions.cpp")
            
      expected_destination = File.read("test/files/destination.cpp")
      new_destination = File.read("test/tmp/destination.cpp")

      assert_equal expected_destination, new_destination
      assert_equal "", stdout.chomp
    end
  end
end
