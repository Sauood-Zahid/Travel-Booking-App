@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Country Value Help'
@Metadata.ignorePropagatedAnnotations: true
@ObjectModel.resultSet.sizeCategory: #XS // Isse dropdown direct khulta hai
define view entity ZI_COUNTRY_VH_419 
  as select from ztravel_book_419
{
  key 'Pakistan' as Country
} union select from ztravel_book_419 {
  key 'UAE' as Country
} union select from ztravel_book_419 {
  key 'Turkey' as Country
} union select from ztravel_book_419 {
  key 'Malaysia' as Country
} union select from ztravel_book_419 {
  key 'Saudi Arabia' as Country
}
