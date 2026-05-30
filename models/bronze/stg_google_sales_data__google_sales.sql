with 

source as (

    select * from {{ source('google_sales_data', 'google_sales') }}

),

renamed as (

    select

    from source

)

select * from renamed