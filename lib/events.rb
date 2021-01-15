module EVENTS
    GENERAL='General Inquiry'
  
    def create_general_event_data(lead_source, lead_system, message, first_name, last_name, emails, phones)
      parsed_emails = []
      parsed_phones = []
  
      emails.each do |email|
        parsed_emails.push("value": email)
      end
  
      phones.each do |phone|
        parsed_phones.push("value": phone)
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