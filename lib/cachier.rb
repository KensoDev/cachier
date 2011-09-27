# Cachier
module Cachier
  extend self

  CACHE_KEY = 'Cachier-tags'

  def perform_caching?
    ::ApplicationController.perform_caching
  end
  
  # Fetch something from cache and tag it
  def fetch_from_cache(cache_key, cached_object, cache_params = {})
    tags = cache_params.delete(:tag) || []

    add_tags_to_tag_list(tags) if tags.length > 0

    returned_object = Rails.cache.fetch(cache_key, cache_params) {
      cached_object
    }

    returned_object
  end

  def store_fragment(fragment, *tags)
    return unless perform_caching?

    tags.each do |tag|
      # store the fragment
      fragments = Rails.cache.fetch(tag) || []
      Rails.cache.write(tag, fragments + [fragment])
    end

    # now store the tag for book keeping
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
      arry += Rails.cache.fetch(tag)
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