delimiter $$

use ChsPaddler $$

drop procedure if exists availableTours $$

create procedure availableTours (in tourDate date)

begin
drop table if exists hours;
create temporary table hours (tourTime time);
insert into hours values ('09:00:00'), ('13:00:00'), ('15:00:00');

select `tourTime` from `hours` where `tourTime` not in
	(select date_format(`Time`, '%H:%i:%s') as `tourTime` from `Reservation` where date_format(`Time`, '%Y-%m-%d') = tourDate);

drop table hours;

end