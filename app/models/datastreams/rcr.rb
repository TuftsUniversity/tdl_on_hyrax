# frozen_string_literal: true
require 'om'

module Datastreams
  class Rcr
    include OM::XML::Document
    include OM::XML::TerminologyBasedSolrizer

    set_terminology do |t|
      t.root(:path => "eac-cpf", "xmlns" => "urn:isbn:1-931666-33-4",
             "xmlns:xsi" => "http://www.w3.org/2001/XMLSchema-instance",
             "xmlns:xlink" => "http://www.w3.org/1999/xlink",
             "xsi:schemaLocation" => "urn:isbn:1-931666-33-4 http://eac.staatsbibliothek-berlin.de/schema/cpf.xsd")
      t.recordId(path: "recordId")
      t.maintenanceStatus(path: "maintenanceStatus")
      t.maintenanceAgency(path: "maintenanceAgency")
      t.languageDeclaration(path: "languageDeclaration")
      t.conventionDeclaration(path: "conventionDeclaration")
      t.maintenanceHistory(path: "maintenanceHistory")
      t.sources(path: "sources")
      t.identity(path: "identity") do
        t.nameEntry(path: "nameEntry") do
          t.part(path: "part")
        end
      end
      t.description(path: "description") do
        t.existDates(path: "existDates") do
          t.dateRange(path: "dateRange") do
            t.fromDate(path: "fromDate")
            t.toDate(path: "toDate")
          end
        end
        t.biogHist(path: "biogHist") do
          t.abstract(path: "abstract")
          t.p(path: "p")
        end
        t.structureOrGenealogy(path: "structureOrGenealogy") do
          t.p(path: "p")
          t.list(path: "list") do
            t.item(path: "item")
          end
        end
      end
      t.relations(path: "relations") do
        t.cpfRelation(path: "cpfRelation") do
          t.relationEntry(path: "relationEntry")
          t.dateRange(path: "dateRange") do
            t.fromDate(path: "fromDate")
            t.toDate(path: "toDate")
          end
        end
        t.resourceRelation(path: "resourceRelation") do
          t.relationEntry(path: "relationEntry")
        end
      end

      # Title
      t.title(proxy: [:identity, :nameEntry, :part])
      t.fromDate(proxy: [:description, :existDates, :dateRange, :fromDate])
      t.toDate(proxy: [:description, :existDates, :dateRange, :toDate])

      # Body
      t.bioghist_abstract(proxy: [:description, :biogHist, :abstract])
      t.bioghist_p(proxy: [:description, :biogHist, :p])
      t.structure_or_genealogy_p(proxy: [:description, :structureOrGenealogy, :p])
      t.structure_or_genealogy_item(proxy: [:description, :structureOrGenealogy, :list, :item])

      # Relationships
      t.cpf_relations(proxy: [:relations, :cpfRelation])

      # Collections
      t.resource_relations(proxy: [:relations, :resourceRelation])
    end
  end
end
