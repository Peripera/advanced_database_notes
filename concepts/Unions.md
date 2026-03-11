
## Example of set difference

En este query se indica que se retornen los calores de my brick collection que no aparecen en tu brick collection, sin embargo *no exist* maneja mal null

select colour, shape from your_brick_collection ybc
where  not exists (
  select null from my_brick_collection mbc
  where  ybc.colour = mbc.colour
  and    ybc.shape = mbc.shape
);

### Correct query

select colour, shape from your_brick_collection ybc
where  not exists (
  select null from my_brick_collection mbc
  where  ( ybc.colour = mbc.colour or
    ( ybc.colour is null and mbc.colour is null )
  )
  and    ( ybc.shape = mbc.shape or
    ( ybc.shape is null and mbc.shape is null )
  )
);