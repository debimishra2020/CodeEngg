item_id item                    item_id item                  item_id     item_lists
1       Apple                   7       Apee                  1           Apple, Orange, Napkin
1       Orange                  8       Ghee                  2           Fish, Egg
2       Fish                    8       Apee                  3           Rice
2       Egg                     10      Apple                 4           Dal
3       Rice                    10      Orange                5           Apple, Orange, Tissue Paper
4       Dal                     5       Tissue Paper          6           Orange
5       Apple                   1       Napkins               7           Ghee, Apee
5       Orange                  11      Apple                 8           Ghee, Apee
6       Orange                  11      Orange                10          Apple, Orange
7       Ghee                    11      Tissue Paper          11          Apple, Orange, Tissue Paper

/*Write a query to find the maximum occurrence of items bought together*/
/*Output*/
item_list         item_list_bought_togther
Apple, Orange     4
Apee, Ghee        2
Apple, Tissue     2
Orange, Tissue    2
Apple, Napkins    1
Egg, Fish         1
Napkin, Orange    1

select item_list, count(*) as item_list_bought_togther from (
select concat(concat(a.item, ','),b.item) as item_list
from item a, item b
where a.item_id = b.item_id and a.item <> b.item and a.item < b.item)
group by item_list order by 2 desc;
