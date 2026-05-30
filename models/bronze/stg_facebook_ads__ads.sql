with 

source as (

    select * from {{ source('facebook_ads', 'ads') }}

),

renamed as (

    select

    from source

)

select * from renamed