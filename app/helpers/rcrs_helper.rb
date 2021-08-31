# frozen_string_literal: true
module RcrsHelper
  def self.title(rcr)
    result = ""
    title = rcr.find_by_terms_and_value(:title)
    result = title.first.text if title.present?

    result
  end

  def self.dates(rcr)
    result = ""
    from_date = rcr.find_by_terms_and_value(:fromDate)
    to_date = rcr.find_by_terms_and_value(:toDate)
    result = from_date.first.text if from_date.present?
    result += "-"
    result += to_date.first.text if to_date.present?

    result
  end

  def self.abstract(rcr)
    result = ""
    bioghist_abstract = rcr.find_by_terms_and_value(:bioghist_abstract)
    result = bioghist_abstract.first.text if bioghist_abstract.present?

    result
  end

  def self.history(rcr)
    rcr.find_by_terms_and_value(:bioghist_p)
  end

  def self.structure_or_genealogy_p(rcr)
    rcr.find_by_terms_and_value(:structure_or_genealogy_p)
  end

  def self.structure_or_genealogy_items(rcr)
    rcr.find_by_terms_and_value(:structure_or_genealogy_item)
  end

  def self.relationships(rcr)
    relationship_hash = {
      "reportsTo" => "Reports to",
      "hasReport" => "Has report",
      "isPartOf" => "Part of",
      "hasPart" => "Has part",
      "isMemberOf" => "Member of",
      "hasMember" => "Has member",
      "isPrecededBy" => "Preceded by",
      "isFollowedBy" => "Followed by",
      "isAssociatedWith" => "Associated with",
      "isChildOf" => "Child of",
      "isParentOf" => "Parent of",
      "isCousinOf" => "Cousin of",
      "isSiblingOf" => "Sibling of",
      "isSpouseOf" => "Spouse of",
      "isGrandchildOf" => "Grandchild of",
      "isGrandparentOf" => "Grandparent of"
    }
    result_hash = {}

    relationships = rcr.find_by_terms_and_value(:cpf_relations)
    relationships.each do |relationship|
      data = { name: '', pid: '', from_date: '', to_date: '' }
      relationship.element_children.each do |child|
        data = process_child_data(child, data)
      end

      role = relationship_hash.fetch(relationship.attribute("arcrole").text.sub("http://dca.lib.tufts.edu/ontology/rcr#", ""), "Unknown relationship") # xlink:arcrole in the EAC
      role_array = result_hash.fetch(role, nil)
      if role_array.nil?
        role_array = []
        result_hash.store(role, role_array)
      end
      role_array << data
    end
    result_hash
  end

  def self.process_child_data(child, data)
    if child.name == "relationEntry"
      data[:name] = child.text
      data[:pid] = child.attribute("id") # xml:id in the EAC
    elsif child.name == "dateRange"
      child.element_children.each do |grandchild|
        if grandchild.name == "fromDate"
          data[:from_date] = grandchild.text
        elsif grandchild.name == "toDate"
          data[:to_date] = grandchild.text
        end
      end
    end
    data
  end

  def self.collections(rcr)
    result_array = []
    collections = rcr.find_by_terms_and_value(:resource_relations)

    collections.each do |collection|
      name = ""
      pid = collection.attribute("id").text # xml:id in the EAC

      collection.element_children.each do |child|
        childname = child.name

        if childname == "relationEntry"
          name = child.text
          break
        end
      end

      result_array << { name: name, pid: pid }
    end

    result_array
  end
end
