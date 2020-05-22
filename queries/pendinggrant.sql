SELECT g.*,info.*, grant_sub_type_50 as sub_type, c.display_name,
country_s_working_on country,region_s_working_on_49 region
from civicrm_grants g
join civicrm_contact c on c.id=g.contact_id
left join civicrm_value_grants_additional_information_13 as info on info.entity_id=g.id
left join civicrm_value_grants_sub_type_11 as sub_type on sub_type.entity_id=g.id
left join civicrm_value_1_front_line_contact fld on fld.entity_id=c.id


where status_id=6
order  by application_received_date desc;
/* CREATE VIEW civicrm_grants AS SELECT * from civicrm_grant; */
