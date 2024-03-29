# frozen_string_literal: true
require 'om'

module Datastreams
  class Tei
    include OM::XML::Document
    include OM::XML::TerminologyBasedSolrizer

    set_terminology do |t|
      t.root(path: "TEI.2")

      t.teiHeader(path: "teiHeader", namespace_prefix: nil) do
        t.fileDesc(path: "fileDesc", namespace_prefix: nil) do
          t.titleStmt(path: "titleStmt", namespace_prefix: nil) do
            t.title(path: "title", namespace_prefix: nil)
            t.author(path: "author", namespace_prefix: nil)
          end
        end
        t.profileDesc(path: "profileDesc", namespace_prefix: nil) do
          t.particDesc(path: "particDesc", namespace_prefix: nil) do
            t.person(path: "person", namespace_prefix: nil) do
              t.id_attr(path: { attribute: "id" }, namespace_prefix: nil)
              t.role_attr(path: { attribute: "role" }, namespace_prefix: nil)
              t.p(path: "p", namespace_prefix: nil)
            end
          end
        end
      end

      t.text(path: "text", namespace_prefix: nil) do
        t.body(path: "body", namespace_prefix: nil) do
          t.timeline(path: "timeline", namespace_prefix: nil) do
            t.when(path: "when", namespace_prefix: nil)
          end
          t.div1(path: "div1", namespace_prefix: nil) do
            t.u(path: "u", namespace_prefix: nil) do
              t.who_attr(path: { attribute: "who" }, namespace_prefix: nil)
              t.u_inner(path: "u", namespace_prefix: nil)
            end
          end
        end
      end

      t.title(proxy: [:teiHeader, :fileDesc, :titleStmt, :title])
      t.author(proxy: [:teiHeader, :fileDesc, :titleStmt, :author])

      t.id_attr(proxy: [:teiHeader, :profileDesc, :particDesc, :person, :id_attr])
      t.role_attr(proxy: [:teiHeader, :profileDesc, :particDesc, :person, :role_attr])
      t.p(proxy: [:teiHeader, :profileDesc, :particDesc, :person, :p])
      t.participants(proxy: [:teiHeader, :profileDesc, :particDesc])
      t.when(proxy: [:text, :body, :timeline, :when])
      t.u(proxy: [:text, :body, :div1, :u])
      # t.who_attr(:proxy => [:text, :body, :div1, :u, :u, :who_attr])
      # t.u_inner(:proxy => [:text, :body, :div1, :u, :u_inner])
    end
  end
end
