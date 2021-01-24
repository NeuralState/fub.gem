require 'httparty'
require 'events'

module CALLS
  INTERESTED='Interested'
  NOT_INTERESTED='Not Interested'
  LEFT_MESSAGE='Left Message'
  NO_ANSWER='No Answer'
  BAD_NUMBER='Bad Number'
end


class FUB
  include HTTParty
  debug_output $stdout

  # Base URI or all HTTP calls
  base_uri 'https://api.followupboss.com/v1/'

  @x_sys = {'X-System': '', 'X-System-Key': ''}

  # FUB.new
  # Grab the api_key from the Rails credientials store
  def initialize(api_key, x_system, x_system_key)
    #api_key = Rails.application.credentials.fub[:api_key]
    
    # Set basic auth credentials
    self.class.basic_auth(api_key, '')
    self.class.headers({'X-System': x_system, 'X-System-Key': x_system_key}) 
  end

  # Get all PEOPLE from FUB
  # query: hash of query parameters
  # offset: results begin at this record
  # limit: returns up to 'limit' results
  # Returns people array, metadata array
  # empty array when there is no more data
  def get_people(query: {}, offset: 0, limit: 100)
    return api_get_wrapper(query, offset, limit, 'people')
  end

  def get_people_count(query={})
    people, metadata = api_get_wrapper(query, 0, 1, 'people')
    return metadata['total']
  end

  # Get all USERS from FUB
  # query: hash of query parameters
  # offset: results begin at this record
  # limit: returns up to 'limit' results
  # Returns empty array when there is no more data
  def get_users(offset: 0, limit: 100)
    return api_get_wrapper(nil, offset, limit, 'users')
  end

  def get_user_by_id(id=0)
    return api_get_wrapper(nil, 0, 1, 'users', "/#{id}")
  end

  # Get the calls related to this personid
  # personid: the id of the PERSON
  # nextGroup: true = uses next link to get the next group of results
  def get_calls_by_personid(personId, offset: 0, limit: 100)
    return api_call_wrapper({personId: personId}, offset, limit, 'calls')
  end

  # Saves a new CALL for this personid using note and Calls::outcome
  def save_call_by_personid(personId, phone_number, note, outcome)
    data = {
      :personId => personId,
      :phone => phone_number,
      :note => note,
      :outcome => outcome,
      :isIncoming => 0,
    }
    return api_post_wrapper(data, 'calls')
  end

  def log_incoming_call_by_personid(personId, phone_number, note, duration, outcome)
    data = {
      :personId => personId,
      :phone => phone_number,
      :note => note,
      :outcome => outcome,
      :duration => duration,
      :isIncoming => 1,
    }
    return api_post_wrapper(data, 'calls')
  end

  # Get the notes related to this personid
  # personid: the id of the PERSON
  # offset: results begin at this record
  # limit: returns up to 'limit' results
  # Returns empty array when there is no more data
  def get_notes_by_personid(personId, type: nil, offset: 0, limit: 100)
    return api_get_wrapper({personId: personId, type: type}, offset, limit, 'notes')
  end

  # Saves a new NOTE for this personid using note and Calls::outcome
  def save_note_by_personid(personid, subject, body, type)
    data = {
      :personId => personid,
      :subject => subject,
      :body => body,
      :type => type,
      :isHtml => 0,
    }
    return api_post_wrapper(data, 'notes')
  end

  # Posts an event to the system
  def send_event(event_data)
    return api_post_wrapper(event_data, 'events')
  end

  # Gets all STAGES associated with the PEOPLE
  # nextGroup: true = uses next link to get next group of results
  # limit: returns up to 'limit' results
  # Returns empty array when there is no more data
  def get_stages(query: {}, offset: 0, limit: 100)
    return api_get_wrapper(query, offset, limit, 'stages')
  end
  
  # Gets all the PIPELINES
  # nextGroup: true = uses next link to get next group of results
  # limit: returns up to 'limit' results
  # Returns empty array when there is no more data

  def get_pipelines(query={}, limit=100)
    return api_get_wrapper(nextGroup, query, limit, 'pipelines')
  end

  # Gets all the DEALS
  # nextGroup: true = uses next link to get next group of results
  # limit: returns up to 'limit' results
  # Returns empty array when there is no more data
  def get_deals(nextGroup=false, query={}, limit=100)
    return api_get_wrapper(nextGroup, query, limit, 'deals')
  end

  # Gets all the TASKS
  # nextGroup: true = uses next link to get next group of results
  # limit: returns up to 'limit' results
  # Returns empty array when there is no more data
  def get_tasks(nextGroup=false, query={}, limit=100)
    return api_get_wrapper(nextGroup, query, limit, 'tasks')
  end
  
  
  private
    # Private wrapper function to wrap DRY logic
    def api_get_wrapper(query, offset, limit, api_endpoint, url_part='')

      # Set up the query offset and limit options
      options = { query: {offset: offset, limit: limit}}

      # Merge in the query options if any
      if query && query.length > 0
        options[:query].merge!(query)
      end

      # Make the API call
    endpoint = self.class.get('/' + api_endpoint + url_part, options)

      # should check for too many requests error
      #if (endpoint.code == )
      if (endpoint.code == 200)
        # return the array from the endpoint, and the metadata array
        if endpoint[api_endpoint] == nil
          return endpoint
        else
          return endpoint[api_endpoint], endpoint['_metadata']
        end
      end

      return nil
    end

    def api_post_wrapper(data, api_endpoint)

      # Set up the options
      options = {}

      # Merge in the data if any
      if data && data.length > 0
        options.merge!({body: data})
      end

      # Make the API call
    endpoint = self.class.post('/' + api_endpoint, options)

      # should check for too many requests error
      #if (endpoint.code == )
      if (endpoint.code == 200 || endpoint.code == 201 || endpoint.code == 204)
        return endpoint
      end

      return false
    end

  end
