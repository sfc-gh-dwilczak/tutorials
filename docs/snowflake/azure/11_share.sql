-- Setup share with the secure view.

-- Create a secure view so they can see that anaylist only sees the useable data.
create or replace secure view raw.azure.shared_pepsi as
    select
        data:id::string as id,
        data:name::string as name,
        data:type::string as type,

        -- Properties
        data:properties:createdBy::string as created_by,
        REPLACE(data:properties:createdDate, 'T', ' ')::timestamp as created_date,
        data:properties:createdService::string as created_service,
        data:properties:modifiedBy::string as modified_by,
        REPLACE(data:properties:modifiedDate, 'T', ' ')::timestamp as modified_date,
        data:properties:modifiedService::string as modified_service,

        -- Three subsets.
        data:data:attributes:thgdisplayname::variant as thgdisplayname,
        data:data:attributes:thgidentifier::variant as thgidentifier,
        data:data:relationships:hasimages::variant as hasimages_id
    from
        raw.azure.pepsi;


-- Create a secure view so they can see that anaylist only sees the useable data.
create or replace secure view raw.azure.shared_delta as
    select
        data:id::string as id,
        data:name::string as name,
        data:type::string as type,

        -- Properties
        data:properties:createdBy::string as created_by,
        REPLACE(data:properties:createdDate, 'T', ' ')::timestamp as created_date,
        data:properties:createdService::string as created_service,
        data:properties:modifiedBy::string as modified_by,
        REPLACE(data:properties:modifiedDate, 'T', ' ')::timestamp as modified_date,
        data:properties:modifiedService::string as modified_service,

        -- Three subsets.
        data:data:attributes:thgdisplayname::variant as thgdisplayname,
        data:data:attributes:thgidentifier::variant as thgidentifier,
        data:data:relationships:hasimages::variant as hasimages_id
    from
        raw.azure.delta;


-- GUI TIME: 
  -- Go to "Provider Studio" under data and create a listing.
    -- For this demo we will only share to a specific consumer.
    -- Follow the prompts on the page.

-- If you want to test sharing data my account locater is:
  -- SFSENORTHAMERICA.DEMO_DWILCZAK 
