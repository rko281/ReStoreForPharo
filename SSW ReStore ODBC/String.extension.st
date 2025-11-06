Extension { #name : #String }

{ #category : #'*SSW ReStore ODBC' }
String class >> dbMaxFieldSize [

	"The receiver represents the unsized character column concept in the database, therefore the max field size is undefined"

	^nil
]
