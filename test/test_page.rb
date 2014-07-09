# encoding: utf-8


require 'helper'


class TestPage < MiniTest::Unit::TestCase

  def xxx_test_mx
    page = Factbook::Page.new( 'mx' )
    
    ## print first 600 chars
    pp page.html[0..600]
    
    doc = page.doc

    panels    = doc.css( '.CollapsiblePanel' )
    questions = doc.css( '.question' )
    answers   = doc.css( '.answer' )

    puts "panels.size:    #{panels.size}"
    puts "questions.size: #{questions.size}"
    puts "answers.size:   #{answers.size}"

    cats0      = panels[0].css( '.category' )
    cats0_data = panels[0].css( '.category_data' )

    puts "cats0.size:       #{cats0.size}"
    puts "cats0_data.size:  #{cats0_data.size}"

    cats1      = panels[1].css( '.category' )
    cats1_data = panels[1].css( '.category_data' )

    puts "cats1.size:       #{cats1.size}"
    puts "cats1_data.size:  #{cats1_data.size}"


    ## fix: use cats -- add s
    cat = doc.css( '#CollapsiblePanel1_Geo div.category' )
    puts "cat.size: #{cat.size}"

    catcheck = doc.css( '#CollapsiblePanel1_Geo .category' )
    puts "catcheck.size: #{catcheck.size}"

    catcheck2 = doc.css( '.category' )
    puts "catcheck2.size: #{catcheck2.size}"


    catdata = doc.css( '#CollapsiblePanel1_Geo .category_data' )
    puts "catdata.size: #{catdata.size}"

    catdatacheck2 = doc.css( '.category_data' )
    puts "catdatacheck2.size: #{catdatacheck2.size}"

    puts "catdata[0]:"
    pp catdata[0]

    puts "catdata[1]:"
    pp catdata[1]

#    puts "catdata[2]:"
#    pp catdata[2]

#    puts "catdata[0].text():"
#    pp catdata[0].text()

#    puts "cat[0].text():"
#    pp cat[0].text()

#    cat.each_with_index do |c,i|
#      puts "[#{i+1}]: ========================="
#      puts ">>#{c.text()}<<"
#    end

  end

  def test_mx
    page = Factbook::Page.new( 'mx' )
    
    ## print first 600 chars
    pp page.html[0..600]
    
    ## save for debuging
    
    puts "saving a copy to mx.html for debugging"
    File.open( 'mx.html', 'w') do |f|
      f.write( page.html )
    end

    doc   = page.doc
    sects = page.sects

    panels    = doc.css( '.CollapsiblePanel' )
    questions = doc.css( '.question' )
    answers   = doc.css( '.answer' )

    puts "panels.size:    #{panels.size}"
    puts "questions.size: #{questions.size}"
    puts "answers.size:   #{answers.size}"

    rows_total = 0
    panels.each_with_index do |panel,i|
      rows = panel.css( 'table tr' )
      puts "  [#{i}] rows.size:  #{rows.size}"
      rows_total += rows.size
    end

    puts "rows_total: #{rows_total}"


    ## stats( doc )

    sects.each_with_index do |sect,i|
      puts ''
      puts "############################"
      puts "#### stats sect #{i}:"
      stats( sect )
    end
  end


  def stats( doc )
    rows  = doc.css( 'table tr' )
    puts "rows.size:    #{rows.size}"
 
    ## check rows
    rows.each_with_index do |row,i|
      ## next if i > 14   ## skip after xx for debugging for now

      cats      = row.css( '.category' )
      cats_data = row.css( '.category_data' )
      field_ids = row.css( '#field' )    ## check - use div#field.category -- possible?
      data_ids  = row.css( '#data' )


      ## check for subcategory
      ##   must be div w/ id field and class category

      if cats.size == 1 && field_ids.size == 1 && cats_data.size == 0 && cats.first.name == 'div'
        text = cats.first.text.strip   # remove/strip leading and trailing spaces
        puts "  [#{i}] category: >>#{text}<<"
      elsif field_ids.size == 1
        puts "**** !!!!!! warn/err - found element w/ field id  (no match for subsection!!! - check)"
      elsif cats.size == 0 && cats_data.size == 1   ## check for cats_data.first.name == 'div' too ???
        text = cats_data.first.text.strip   # remove/strip leading and trailing spaces
        puts "       - [#{i}] data: >>#{text}<<"
      elsif cats.size == 0 && cats_data.size > 1   ## check for cats_data.first.name == 'div' too ???
        ary = []
        cats_data.each do |cat_data|
          ary << cat_data.text.strip
        end
        text = ary.join( '; ' )
        puts "       - [#{i}] data#{cats_data.size}: >>#{text}<<"
      elsif cats.size > 0  ## check for data = 1 ????
        if data_ids.size != 1
          puts "**** !!!!! [#{i}] cats:   #{cats.size},  cats_data: #{cats_data.size}, data_ids: #{data_ids.size}"
        else
          puts "     [#{i}] cats:   #{cats.size},  cats_data: #{cats_data.size}, data_ids: #{data_ids.size}"
        end
        
        cats.each_with_index do |cat,j|  # note: use index - j (for inner loop)
          ## get text from direct child / children
          ##  do NOT included text from  nested span - how? possible?
          ## text = cat.css( ':not( .category_data )' ).text.strip  ## will it include text node(s)??
          ## text = cat.text.strip  ## will it include text node(s)??
          ## text =  cat.css( '*:not(.category_data)' ).text.strip
          # Find the content of all child text nodes and join them together
          text = cat.xpath('text()').text.strip
          n  = cat.css( '.category_data' )
          ## or use
          ## text = cat.children.first.text ??
          puts "     -- [#{j}] subcategory: >>#{text}<<  cats_data: #{n.size}"
          ## pp cat.css( '*:not(.category_data)' )
          ## pp cat.css( "*:not(*[@class='category_data'])" )   # *[@class='someclass']
          ## pp cat
          ## check if is div - if not issue warn
          if cat.name == 'div'
            ## check if includes one or more category_data nodes
            if n.size == 0
              puts "         ****** !!! no category_data inside"
            end
            if n.size > 1
              puts "         ****** !!! multiple category_data's inside - #{n.size}"
            end
          else
            puts "         ****** !!!! no div - is >>#{cat.name}<<"
          end
        end
      else
        puts "**** !!!!!!! [#{i}] cats:   #{cats.size},  cats_data: #{cats_data.size}, data_ids: #{data_ids.size}"
      end


      if cats.size > 1
        ## puts row.to_s
      end
   end # each row

  end


end # class TestPage
