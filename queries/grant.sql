SELECT g.*,c.first_name from civicrm_grants g
join civicrm_contact c on c.id=g.contact_id
order  by application_received_date desc;
/* CREATE VIEW civicrm_grants AS SELECT * from civicrm_grant; */
