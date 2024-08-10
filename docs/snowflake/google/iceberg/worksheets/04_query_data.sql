use database raw;
use schema gcp;
use role sysadmin;
use warehouse developer;

select * from RAW.GCP.JSON;

----- Flattened 

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
    raw.gcp.json;



