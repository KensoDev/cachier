# Cachier
module Cachier
  extend self

  CACHE_KEY = 'cachier-tags'

  def perform_caching?
    ::ApplicationController.perform_caching
  end

  # Fetch from cache, this function accepts a block
  def fetch(cache_key, cache_params = {})
    tags = cache_params.delete(:tag) || []
    store_fragment(cache_key, tags)

    if block_given?
      returned_object = Rails.cache.fetch(cache_key, cache_params) {
        yield
      }  
    else
      Rails.cache.read(cache_key)
    end
  end

  def store_fragment(fragment, *tags)
    return unless perform_caching?

    tags.each do |tag|
      fragments = Rails.cache.fetch(tag) || []
      Rails.cache.write(tag, fragments + [fragment])
    end

    add_tags_to_tag_list(tags)
  end

  def expire(*tags)
    return unless perform_caching?

    # delete them from the cache
    tags.each do |tag|
      if fragment_keys = Rails.cache.fetch(tag)
        fragment_keys.each do |fragment_key|
          Rails.cache.delete(fragment_key)
        end
      end
      
      Rails.cache.delete(tag)
    end

    # now remove them from the list
    # of stored tags
    remove_tags_from_tag_list(tags)
  end

  def tags
    Rails.cache.fetch(CACHE_KEY) || []
  end

  def clear
    expire(*tags)
    Rails.cache.delete(CACHE_KEY)
  end

  def wipe
    clear
  end

  def keys
    tags.inject([]) do |arry, tag|
      arry += (Rails.cache.fetch(tag) || [])
    end.compact
  end

  def keys_for(tag)
    Rails.cache.fetch(tag) || []
  end

  private
    def add_tags_to_tag_list(*tags)
      cachier_tags = get_cachier_tags

      cachier_tags = (cachier_tags + tags).uniq
      write_cachier_tags(cachier_tags)
    end

    def write_cachier_tags(cachier_tags)
      Rails.cache.write(CACHE_KEY, cachier_tags)
    end

    def remove_tags_from_tag_list(*tags)
      cachier_tags = get_cachier_tags

      cachier_tags = (cachier_tags - tags).uniq
      write_cachier_tags(cachier_tags)
    end

    def get_cachier_tags
      cachier_tags = Rails.cache.fetch(CACHE_KEY) || []
      cachier_tags
    end
end

require 'cachier/controller_helper'
require 'cachier/matchers'