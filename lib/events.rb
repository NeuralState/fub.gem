module EVENTS
    GENERAL='General Inquiry'
  
    def create_general_event_data(lead_source, lead_system, message, first_name, last_name, emails, phones)
      parsed_emails = []
      parsed_phones = []
  
      if emails.kind_of? String
        parsed_emails.push("value": emails)
      elsif emails.kind_of? Array
        emails.each do |email|
          parsed_emails.push("value": email)
        end
      end

      if phones.kind_of? String
        parsed_phones.push("value": phones)
      elsif phones.kind_of? Array
        phones.each do |phone|
          parsed_phones.push("value": phone)
        end
      end
  
      person = {
        "firstName": first_name,
        "lastName": last_name,
        "email": parsed_emails,
        "phones": parsed_phones,
      }
  
      data = {
        "source": lead_source,
        "system": lead_system,
        "type": GENERAL,
        "message": message,
        "person": person
      }
  
      return data
    end

    module_function :create_general_event_data
  end