module Incodesert
  
  # Documents holds all three documents involved in an incodesert insertion.
  # Those three documents are:
  # * The source:  A String holding the blocks to be inserted delimited by special 
  #   comments.
  # * The destination:  A String to receive the insertions that contains insertion 
  #   points delimited by the same comments as appear in the source.
  # * The extractions:  A String of all the blocks that were removed in the destination
  #   in order to be replaced by the source.  This can be useful to revert the changes.
  #
  # Documents also performs the insertion upon calling +perform_insertions!+
  # 
  # Author:: Kirk Bowers (mailto:kirkbowers@yahoo.com)
  # Copyright:: Copyright (c) 2015 Kirk Bowers
  # License:: MIT License
  class Documents
    
    attr_accessor :source
    attr_accessor :destination
    attr_reader   :extractions
    attr_reader   :warnings
    
    attr_accessor :replacements
        
    attr_accessor :verbose
    attr_accessor :no_warn
    attr_accessor :source_name

    def initialize(source = "", destination = "")
      @source = source
      @destination = destination
      @extractions = []
      @warnings = []

      @replacements = {}      
      
      @verbose = false
      @no_warn = false
      @source_name = nil
    end
    
    # Shadow global warn function
    def warn(message)
      @warnings.push message
    end
    
    def perform_insertions!
      process_source
      
      process_destination
      
      @destination = @destination.join("\n")
      @extractions = @extractions.join("\n")
      # Add an extra newline to extractions so it doesn't end without one if non-empty
      @extractions += "\n" if @extractions != ""
      
      @warnings = @warnings.join("\n")
      @warnings += "\n" if @warnings != ""
    end
    
    #-----------------------------------------------------------
    private
    
    def process_source
      @blocks = {}
      @current_block_name = ""
      
      # The "-1" is an unintuitive way of saying don't trim off trailing newlines.
      # We want to preserve the source exactly.
      lines = @source.split("\n", -1)
      
      lines.each do |line|
        # If we match either a C-style or script style comment, exactly 3 < (in) chars,
        # one or more spaces, then anything as a token (even including spaces)
        # that opens a source block
        if line =~ /^(\s*(\/{2}|#))\s+<{3}\s+(.+)/
          open_source_block(line, $1, $3)
        # Similarly, match a comment, exactly 3 > (out) chars, and a token,
        # close the block
        elsif line =~ /^\s*(\/{2}|#)\s+>{3}\s+(.+)/
          close_source_block(line, $2)
        # If we are in a current block, remember this line
        elsif @current_block_name != ""
          @current_block.push(line)
        end
      end
    end
      
    def open_source_block(line, comment, name)
      name = name.rstrip
      puts "Source:  open block: #{name}" if @verbose
      @current_block_name = name
      @current_block = [line]
      unless @no_warn
        @current_block.push("#{comment}")
        @current_block.push("#{comment} WARNING!!! This code auto-inserted by incodesert")
        @current_block.push("#{comment} Do not edit this block!")
        if @source_name
          @current_block.push("#{comment} If you need to make changes, edit the source: #{@source_name}")
        end
      end
    end
    
    def close_source_block(line, name)
      name = name.rstrip
      puts "Source: close block: #{name}" if @verbose
      if name == @current_block_name
        @current_block.push(line)
        @blocks[name] = @current_block
      else
        warn "In source: open and close blocks do not match!!"
        warn "Opened with #{@current_block_name}"
        warn "Closed with #{name}"
      end

      # Either way, we've attempted to close a block, so clear the current block name
      # to signify we are not currently in a block at all.
      @current_block_name = ""
    end
    
    
    def process_destination  
      @current_block_name = ""
      @extractions = []
      
      lines = @destination.split("\n", -1)

      # We're going to rebuild the destination from scratch now
      @destination = []
      
      lines.each do |line|
        if line =~ /^\s*(\/{2}|#)\s+<{3}\s+(.+)/
          open_destination_block(line, $2)
        elsif line =~ /^\s*(\/{2}|#)\s+>{3}\s+(.+)/
          close_destination_block(line, $2)
        elsif @current_block_name != ""
          @current_block.push(line)
        else
          @destination.push(line)
        end
      end      
    end
    
    def open_destination_block(line, name)
      name = name.rstrip
      puts "Destination:  open block: #{name}" if @verbose
      @current_block_name = name
      @current_block = [line]
    end
    
    def close_destination_block(in_line, name)
      name = name.rstrip
      puts "Destination: close block: #{name}" if @verbose

      @current_block.push(in_line)

      if name == @current_block_name
        lines_to_insert = @blocks[name]
        
        if lines_to_insert.nil?
          # There was no such block in the source
          # We need to leave this block as is in the destination
          @destination.concat(@current_block)
        else
          puts "Destination: matched block from source, replacing" if @verbose
          lines_to_insert.each do |line|
            result = ""
            # This nasty bit of logic lets us scan through each line to insert and
            # see if have any __ delimited tokens to possibly replace.
            # Some languages, like ruby and python, do have variables with names that
            # match this pattern.  Our tokens here are all caps, so there's very little
            # chance of a clash.  Any __ surrounded thing we see but don't recognize
            # should be left as is.  Otherwise we replace.
            while line.length > 0
              match = /(__(\w+)__)/.match(line)
              if match
                replacement = @replacements[match[2]]
                if replacement
                  result += match.pre_match + replacement
                else
                  # There's probably a cleaner way to do this, but it works.
                  result += match.pre_match + match[1]
                end
                # Advance the part of the line we're looking at
                line = match.post_match
              else
                # No match, consume all that's left
                result += line
                line = ""
              end
            end
            
            @destination.push(result)
          end
          
          # Preserve the replaced block
          @extractions.concat(@current_block)
        end
      
      else
        # Pass the current block through unmodified
        @destination.concat(@current_block)
      
        warn "In Destination: open and close blocks do not match!!"
        warn "Opened with #{@current_block_name}"
        warn "Closed with #{name}"
      end

      # Either way, we've attempted to close a block, so clear the current block name
      # to signify we are not currently in a block at all.
      @current_block_name = ""      
    end
    
  end
end
