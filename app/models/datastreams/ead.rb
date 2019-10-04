require 'om'

module Datastreams
  class Ead
    include OM::XML::Document
    include OM::XML::TerminologyBasedSolrizer

    set_terminology do |t|
      # Since our old EADs have xmlns="http://dca.tufts.edu/schema/ead" and our new
      # ArchivesSpace-generated EADs have xmlns="urn:isbn:1-931666-22-9", do not
      # specify a namespace so that either (or any future) namespace will work.
      t.root(path: "ead")

      t.eadheader(path: "eadheader") do
        t.eadid(path: "eadid")
        t.filedesc(path: "filedesc") do
          t.titlestmt(path: "titlestmt") do
            t.titleproper(path: "titleproper")
            t.sponsor(path: "sponsor")
          end
          t.publicationstmt(path: "publicationstmt") do
            t.publisher(path: "publisher")
            t.address(path: "address") do
              t.addressline(path: "addressline")
            end
            t.date(path: "date")
          end
        end
      end

      t.frontmatter(path: "frontmatter") do
        t.titlepage(path: "titlepage") do
          t.titleproper(path: "titleproper")
          t.num(path: "num")
          t.publisher(path: "publisher")
          t.address(path: "address") do
            t.addressline(path: "addressline")
          end
          t.date(path: "date")
        end
      end

      t.archdesc(path: "archdesc") do
        t.did(path: "did") do
          t.head(path: "head")
          t.repository(path: "repository") do
            t.corpname(path: "corpname")
            t.address(path: "address") do
              t.addressline(path: "addressline")
            end
          end
          t.origination(path: "origination") do
            t.persname(path: "persname")
            t.corpname(path: "corpname")
            t.famname(path: "famname")
          end
          t.unittitle(path: "unittitle")
          t.unitdate(path: "unitdate")
          t.physdesc(path: "physdesc")
          t.unitid(path: "unitid")
          t.abstract(path: "abstract")
          t.langmaterial(path: "langmaterial")
        end

        t.bioghist(path: "bioghist") do
          t.head(path: "head")
          t.note(path: "note") do
            t.p(path: "p")
          end
          t.p(path: "p")
        end

        t.scopecontent(path: "scopecontent") do
          t.head(path: "head")
          t.note(path: "note") do
            t.p(path: "p")
          end
          t.p(path: "p")
        end

        t.arrangement(path: "arrangement") do
          t.head(path: "head")
          t.note(path: "note") do
            t.p(path: "p")
          end
          t.p(path: "p")
        end

        t.accessrestrict(path: "accessrestrict") do
          t.head(path: "head")
          t.p(path: "p")
        end

        t.userestrict(path: "userestrict") do
          t.head(path: "head")
          t.p(path: "p")
        end

        t.phystech(path: "phystech") do
          t.head(path: "head")
          t.p(path: "p")
        end

        t.prefercite(path: "prefercite") do
          t.head(path: "head")
          t.p(path: "p")
        end

        t.descgrp(path: "descgrp") do
          t.accessrestrict(path: "accessrestrict") do
            t.head(path: "head")
            t.p(path: "p")
          end

          t.userestrict(path: "userestrict") do
            t.head(path: "head")
            t.p(path: "p")
          end

          t.phystech(path: "phystech") do
            t.head(path: "head")
            t.p(path: "p")
          end

          t.prefercite(path: "prefercite") do
            t.head(path: "head")
            t.p(path: "p")
          end
        end

        t.controlaccess(path: "controlaccess") do
          t.head(path: "head")
          t.controlaccess(path: "controlaccess")
        end

        t.accruals(path: "accruals") do
          t.head(path: "head")
          t.p(path: "p")
        end

        t.appraisal(path: "appraisal") do
          t.head(path: "head")
          t.p(path: "p")
        end

        t.altformavail(path: "altformavail") do
          t.head(path: "head")
          t.p(path: "p")
        end

        t.originalsloc(path: "originalsloc") do
          t.head(path: "head")
          t.p(path: "p")
        end

        t.otherfindaid(path: "otherfindaid") do
          t.head(path: "head")
          t.p(path: "p") do
            t.extref(path: "extref")
            t.extptr(path: "extptr")
          end
        end

        t.dsc(path: "dsc") do
          t.c01(path: "c01") do
            t.did(path: "did")
            t.arrangement(path: "arrangement")
            t.scopecontent(path: "scopecontent") do
              t.note(path: "note") do
                t.p(path: "p")
              end
              t.p(path: "p")
            end

            t.c02(path: "c02") do
              t.did(path: "did") do
                t.unittitle(path: "unittitle")
              end
            end
          end

          t.c(path: "c") do
            t.did(path: "did")
            t.arrangement(path: "arrangement")
            t.scopecontent(path: "scopecontent") do
              t.note(path: "note") do
                t.p(path: "p")
              end
              t.p(path: "p")
            end

            t.c(path: "c") do
              t.did(path: "did") do
                t.unittitle(path: "unittitle")
              end
            end
          end
        end

        t.separatedmaterial(path: "separatedmaterial") do
          t.head(path: "head")
          t.p(path: "p")
        end
        t.relatedmaterial(path: "relatedmaterial") do
          t.head(path: "head")
          t.p(path: "p") do
            t.archref(path: "archref")
          end
        end
        t.processinfo(path: "processinfo") do
          t.head(path: "head")
          t.p(path: "p")
        end
        t.acqinfo(path: "acqinfo") do
          t.head(path: "head")
          t.p(path: "p")
        end
        t.custodhist(path: "custodhist") do
          t.head(path: "head")
          t.p(path: "p")
        end
      end

      # Overview
      t.eadid(proxy: [:eadheader, :eadid])
      t.publicationstmt(proxy: [:eadheader, :filedesc, :publicationstmt])
      t.unittitle(proxy: [:archdesc, :did, :unittitle])
      t.unitdate(proxy: [:archdesc, :did, :unitdate])
      t.persname(proxy: [:archdesc, :did, :origination, :persname])
      t.corpname(proxy: [:archdesc, :did, :origination, :corpname])
      t.famname(proxy: [:archdesc, :did, :origination, :famname])
      t.unitid(proxy: [:archdesc, :did, :unitid])
      t.physdesc(proxy: [:archdesc, :did, :physdesc])
      t.abstract(proxy: [:archdesc, :did, :abstract])
      t.langmaterial(proxy: [:archdesc, :did, :langmaterial])

      # Description
      t.scopecontentp(proxy: [:archdesc, :scopecontent, :p])
      t.arrangementp(proxy: [:archdesc, :arrangement, :p])

      # Biography/History
      t.bioghistp(proxy: [:archdesc, :bioghist, :p])

      # Access and Use
      t.accessrestrictp(proxy: [:archdesc, :accessrestrict, :p])
      t.descgrpaccessrestrictp(proxy: [:archdesc, :descgrp, :accessrestrict, :p])
      t.userestrictp(proxy: [:archdesc, :userestrict, :p])
      t.descgrpuserestrictp(proxy: [:archdesc, :descgrp, :userestrict, :p])
      t.phystechp(proxy: [:archdesc, :phystech, :p])
      t.descgrpphystechp(proxy: [:archdesc, :descgrp, :phystech, :p])
      t.prefercitep(proxy: [:archdesc, :prefercite, :p])
      t.descgrpprefercitep(proxy: [:archdesc, :descgrp, :prefercite, :p])

      # Collection History
      t.processinfop(proxy: [:archdesc, :processinfo, :p])
      t.acqinfop(proxy: [:archdesc, :acqinfo, :p])
      t.custodhistp(proxy: [:archdesc, :custodhist, :p])
      t.accrualsp(proxy: [:archdesc, :accruals, :p])
      t.appraisalp(proxy: [:archdesc, :appraisal, :p])
      t.sponsor(proxy: [:eadheader, :filedesc, :titlestmt, :sponsor])

      # Related Resources
      t.controlaccess(proxy: [:archdesc, :controlaccess])
      t.relatedmaterialp(proxy: [:archdesc, :relatedmaterial, :p])
      t.separatedmaterialp(proxy: [:archdesc, :separatedmaterial, :p])
      t.altformavailp(proxy: [:archdesc, :altformavail, :p])
      t.originalslocp(proxy: [:archdesc, :originalsloc, :p])
      t.otherfindaidp(proxy: [:archdesc, :otherfindaid, :p])

      # Series Descriptions
      t.series(proxy: [:archdesc, :dsc, :c01])

      # Series Descriptions - new ArchivesSpace style
      t.aspaceseries(proxy: [:archdesc, :dsc, :c])
    end
  end
end
