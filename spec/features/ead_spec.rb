require 'rails_helper'
# i_need_ldap              comment back in when ldap is ready

feature 'EAD' do
  # include TestHelpers    comment back in when ldap is ready

  before(:all) do
    FactoryBot.create(:tufts_MS999_ead)
    FactoryBot.create(:tufts_MS226_ead)
  end

  # The MS999 EAD fixture is a new ASpace EAD.
  scenario 'View MS999 (Lorem Ipsum papers/"kitchen sink") landing page' do
    visit '/concern/eads/ks65hc20t'
    page.should have_text 'Lorem Ipsum papers, 1897 -- 1933'
    page.should have_text 'This collection has:'
    page.should have_text '585 Cubic Feet'
    page.should have_text '487 record cartons and 1 document case'
    page.should have_text '197 Gigabytes'
    page.should have_text '95 Cassettes'
    page.should have_text 'The papers of Lorem Ipsum, noted scholar and salon host, consist of his personal and professional papers, including a wide range of correspondence with noted thinkers, scholars, and chorus girls of the 1910s and 1920s.'
    # page.should_not have_text 'View Online Materials'

    click_link "View Finding Aid", exact: false
    page.should have_text "Lorem Ipsum papers, 1897-1933"
    page.should have_text "Title: Lorem Ipsum papers"
    page.should have_text "Dates: 1897 -- 1933"
    page.should have_text "Bulk Dates: 1910 -- 1933"
    page.should have_text "Creator: Ipsum, Lorem, 1850-1933"
    page.should have_text "Call Number: MS999"
    page.should have_text "Size: 585 Cubic Feet, 487 record cartons and 1 document case, 197 Gigabytes, 95 Cassettes"
    page.should have_text "Language(s): Materials are in English, French, and Russian."
    page.should have_text "Permanent URL: http://hdl.handle.net/fake/false"
    page.should have_text "Location:"
    page.should have_text "Digital Collections and Archives, Tufts University"
    page.should_not have_text "35 Professors Row"
    page.should_not have_link "https://dca.tufts.edu/themes/custom/dca_foundation/images/logos/full_with_icon.svg", href: "https://dca.tufts.edu/themes/custom/dca_foundation/images/logos/full_with_icon.svg"
    page.should have_text "archives@tufts.edu"
    page.should have_link "https://dca.tufts.edu/", href: "https://dca.tufts.edu/"
    page.should have_text "The Lorem Ipsum papers consist of his personal and professional papers."
    page.should have_text "Professional papers include manuscripts, speeches, drafts of journal articles, and notes."
    page.should have_text "Personal papers include diaries and correspondence with noted thinkers, scholars, and chorus girls of the 1910s and 1920s, including F. Scott and Zelda Fitzgerald, William James, and Louise Brooks. Sketchbooks are included under diaries for no good reason."
    page.should have_text "Diaries cover the years 1910-1933 with a suspicious gap in 1922."
    page.should have_text "This collection is arranged in two series."
    page.should have_text "Life Events"
    page.should have_text "Lorem Ipsum was born in Peoria, Illinois, in 1850."
    page.should have_text "He died in 1933 and left his extensive collections of rare books and autographed playbills to his alma mater."
    page.should have_text "Cultural Impact"
    page.should have_text "Lorem Ipsum is notorious in urban legend for many matchmaking stunts."
    page.should have_text "Open to research."
    page.should have_text "Copyright has been retained by donor. Researchers are responsible for contacting copyright holders."
    page.should have_text "This collection has no technical requirements for access."
    page.should have_text "Lorem Ipsum papers, 1897-1933. Tufts University. Digital Collections and Archives. Medford, MA."
    page.should have_text "Processed in 2016 by Samantha Redgrave."
    page.should have_text "Gift of Harold Lloyd III, 2016."
    page.should have_text "Although Ipsum's rare books were safely ensconced at Oberlin,"
    page.should have_text "No further accruals are expected."
    page.should have_text "Duplicate materials were discaded during processing, as was Mr. Ipsum's rather careworn feather boa."
    page.should have_text "Processing funded by a generous grant from NEH, 2015."
    page.should have_text "University of Chicago"
    page.should have_link "Adolescence", href: Rails.application.routes.url_helpers.search_catalog_path(q: "Adolescence", search_field: "subject")
    page.should have_link "Advertising", href: Rails.application.routes.url_helpers.search_catalog_path(q: "Advertising", search_field: "subject")
    page.should have_link "Medford", href: Rails.application.routes.url_helpers.search_catalog_path(q: "Medford", search_field: "title")
    page.should have_text "Lorem Ipsum rare book collection, Cornell University."
    page.should have_link "Lorem Ipsum rare book collection", href: "https://fakey.org/fake1"
    page.should have_link "Cornell University", href: "https://fakey.edu/fake2"
    page.should have_text "Taxidermy originally in this collection has been transferred to the Natural History Museum."
    page.should have_link "Natural History Museum", href: "https://fakey.org/fake3"
    page.should have_text "Selected entries are reproduced in The Diary Project"
    page.should have_link "The Diary Project", href: "https://fakey.org/fake5"
    page.should have_text "Lorem Ipsum faculty papers, University of Chicago."
    page.should have_text "This collection is also available on microfilm."
    page.should have_text "Some letters in the correspondence series are photocopies; originals reside with the original authors."
    page.should have_text "A detailed item level list with transcriptions of diaries and letters is available in the repository."
    page.should have_text "Personal papers, 1900 -- 1933"
    page.should have_text "Personal papers consist largely of correspondence and diaries."
    page.should have_text "1.1. Correspondence, 1900 -- 1933"
    page.should have_text "Correspondence with many leading lights of the day,"
    page.should have_text "1.2. Diaries, 1910 -- 1933"
    page.should have_text "Diaries are salacious and gossipy."
    page.should have_text "Professional papers, 1897 -- 1933"
    page.should have_text "Professional papers consists of manuscripts, speeches, notes, and student papers."
    page.should have_text "Speeches are very dull."
    page.should have_text "To see all of websites crawled as part of the Tufts University web collection, please visit the Archive-It collection page."
    page.should have_link "the Archive-It collection page.", href: "https://archive-it.org/collections/1646"

    click_link "Personal papers, 1900 -- 1933", exact: false
    page.should have_text "Personal papers, 1900 -- 1933"
    page.should have_text "This series is part of Lorem Ipsum papers, 1897 -- 1933"
    page.should have_text "Title: Personal papers "
    page.should have_text "Dates: 1900 -- 1933"
    page.should have_text "Bulk Dates: 1910 -- 1933"
    page.should have_text "Call Number: MS999.001"
    page.should have_text "Size: 68 Cubic Feet, 56 record cartons and 2 document cases, 22 Volumes"
    page.should have_text "Language(s): Materials in this series are in English and French."
    page.should have_text "Personal papers consist largely of correspondence and diaries."
    page.should have_text "This series is organized in two subseries."
    page.should have_text "Open for research."
    page.should have_text "Copyright retained by donor."
    page.should have_text "This series has no technical requirements for access."
    page.should have_text "Personal papers, Lorem Ipsum papers, 1897-1933. Tufts University. Digital Collections and Archives. Medford, MA."
    page.should have_text "Evidence suggests that the original processor of this collection may have actually ingested the contents of an envelope marked \"Illegal Fungi,\" which we have been otherwise unable to locate."
    page.should have_text "Gift of Harold Lloyd III, 2016."
    page.should have_text "Upon his death, Ipsum's personal papers were discarded by an unfeeling landlady. They were rescued by a fellow scholar and maintained in a personal collection until they were donated to Tufts University in 2016."
    page.should have_text "No further accruals are expected."
    page.should have_text "Duplicate materials were discaded during processing, as was Mr. Ipsum's rather careworn feather boa."
    page.should have_text "Silk stockings found in this series have been transferred to the Textile Museum."
    page.should have_link "Textile Museum", href: "https://fakey.org/fake4"
    page.should have_text "Letters (correspondence)"
    page.should have_text "Lorem Ipsum rare book collection, Cornell University."
    page.should have_text "Lorem Ipsum faculty papers, University of Chicago."
    page.should have_text "This series is also available on graven tablets."
    page.should have_text "Some letters in the correspondence series are photocopies; originals reside with the original authors."
    page.should have_text "A detailed item level list with transcriptions of diaries and letters is available in the repository."
    page.should have_text "Correspondence 1900 -- 1933"
    page.should have_text "Personal papers consist largely of correspondence and diaries."
    page.should have_text "MS999.001.001"
    page.should have_text "Diaries 1910 -- 1933"
    page.should have_text "Diaries are salacious and gossipy."
    page.should have_text "MS999.001.002"
    page.should have_text "There is also Lorem Ipsum material to be found online. Please visit https://somerandomwebsite.org/collections/LoremIpsum and/or The Lorem Ipsum Collection at someotherrandomwebsite.org."
    page.should have_link "https://somerandomwebsite.org/collections/LoremIpsum", href: "https://somerandomwebsite.org/collections/LoremIpsum"
    page.should have_link "The Lorem Ipsum Collection at someotherrandomwebsite.org", href: "https://someotherrandomwebsite.org/collections/LoremIpsum"
    page.should have_link "New Yorker Cartoons 1922-12-09 - 1927-03-09", href: "https://somerandomwebsite.org/collections/LoremIpsum/NewYorkerCartoons"
    page.should have_text "Lorem Ipsum rare book collection, Cornell University."
    page.should have_link "Lorem Ipsum rare book collection", href: "https://fakey.org/fake1"
    page.should have_link "Cornell University", href: "https://fakey.edu/fake2"
    page.should have_text "Selected entries are reproduced in The Diary Project"
    page.should have_link "The Diary Project", href: "https://fakey.org/fake5"
    page.should have_text "To see all of websites crawled as part of the Tufts University web collection, please visit the Archive-It collection page."
    page.should have_link "the Archive-It collection page.", href: "https://archive-it.org/collections/1646"

    click_link "Correspondence 1900 -- 1933", exact: false
    page.should have_text "Location:"
    page.should have_text "31236554645131"
    page.should_not have_text "Text ("

    visit '/concern/eads/ks65hc20t'
    click_link "View Finding Aid", exact: false
    click_link "Personal papers, 1900 -- 1933", exact: false
    click_link "Diaries 1910 -- 1933", exact: false
    page.should have_text "> Series 1.2: Diaries, 1910 -- 1933"
    page.should have_text "Location:"
    page.should have_text "3123064475432131"
    page.should_not have_text "Books ["
    page.should have_link "Diary 1910", href: "http://hdl.handle.net/false/noreal1"

    click_link "Sketchbooks 1920 -- 1933", exact: false
    page.should have_text "> Series 1.2.1: Sketchbooks, 1920 -- 1933"
    page.should have_text "Sketchbooks reveal surprisingly competent draftsmanship."
    page.should have_text "Sketchbooks are included under diaries for no good reason."
    page.should have_text "Sketchbooks are arranged by binder color in standard ROYGBIV order."
    page.should have_text "Red Sketchbook 1930"
    page.should have_text "Mostly satirical sketches of friends, family and celebrities of the day."
    page.should have_link "Red Sketchbook 1930", href: "http://hdl.handle.net/false/noreal2"
  end

  # The MS226 EAD fixture is an old CIDER EAD.
  scenario 'View MS226 (Rubin Carter papers) landing page' do
    visit '/concern/eads/p2676v52c'
    page.should have_text 'Rubin "Hurricane" Carter papers'
    page.should have_text 'This collection has:'
    page.should have_text '19.20 cubic ft.'
    page.should have_text '6 digital objects'
    page.should have_text 'Rubin “Hurricane” Carter (1937-2014) was a professional boxer and legal rights advocate who spent nearly twenty years in prison for murder convictions that were later overturned.'
    # page.should have_text 'View Online Materials'
    click_link "View Finding Aid", exact: false
    page.should have_text '19.20 cubic ft., 6 digital objects'
    page.should have_text 'Rubin Carter was born on May 6, 1937, in Clifton, New Jersey, to Lloyd and Bertha Carter.'
    page.should have_text 'Sticky notes were left in place.'
    page.should have_text 'This collection was packed by Anne Sauer in May 2013.'
    page.should have_text 'Trials (Murder) -- New Jersey -- Paterson'
    click_link "Awards and artifacts, 1989-06-10-2012", exact: false
    page.should have_text 'Series 1: Awards and artifacts, 1989-06-10-2012'
    page.should have_text '8.40 cubic ft.'
    page.should have_text 'Awards consist of the many honors bestowed on Carter'
    page.should have_text 'This series is arranged in two subseries: 1. Awards; 2. Artifacts.'
    click_link "Awards 1989-06-10-2012", exact: false
    page.should have_text 'Series 1.1: Awards, 1989-06-10-2012'
    page.should have_text 'This series is part of Rubin "Hurricane" Carter papers, 1950-2014'
    page.should have_text 'Positive Impact Celebrity Choice award 2000 '
  end

  #  scenario 'View Online Materials should link to associated materials in search results' do
  #    visit catalog_path(@ead)
  #    click_link 'View Online Materials', :exact => false
  #    page.should have_text 'Alliance for Progress or Alianza Para El Progreso? A Reassessment of the Latin American Contribution to the Alliance for Progress'
  #  end

  #  scenario 'from the Finding Aid Viewer, View Online Materials should link to associated materials in search results' do
  #    visit catalog_path(@ead)
  #    click_link 'View Finding Aid', :exact => false
  #    click_link 'View Online Materials', :exact => false
  #    page.should have_text 'Alliance for Progress or Alianza Para El Progreso? A Reassessment of the Latin American Contribution to the Alliance for Progress'
  #  end

  #  scenario 'MS999 (kitchen sink ASpace EAD) should have a View Finding Aid link;  series should contain items' do
  #    visit catalog_path(@aspace_ead)

  #    click_link 'View Finding Aid', :exact => false
  #    page.should have_text 'Lorem Ipsum papers, 1897-1933'
  #    page.should have_text 'Title: Lorem Ipsum papers'

  #    click_link 'Personal papers, 1900 -- 1933', :exact => false
  #    page.should have_text 'Personal papers, 1900 -- 1933'
  #    page.should have_text 'This series is part of Lorem Ipsum papers, 1897 -- 1933'
  #  end
end
