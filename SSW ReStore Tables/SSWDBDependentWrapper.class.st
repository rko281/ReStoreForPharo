"
ReStore
©2019 John Aspinall
https://github.com/rko281/ReStore
"
Class {
	#name : 'SSWDBDependentWrapper',
	#superclass : 'SSWDBRelatedWrapper',
	#category : 'SSW ReStore Tables',
	#package : 'SSW ReStore Tables'
}

{ #category : 'defining' }
SSWDBDependentWrapper >> defineAs: aSymbol in: aDBTable [

	"Define the wrapped object, making the resulting object dependent"
		
	^(super defineAs: aSymbol in: aDBTable) 
		beDependent;
		yourself
]

{ #category : 'accessing' }
SSWDBDependentWrapper >> dependentObject [

	"dependentObject stores the object for which the receiver represents a database-dependent variant.
	'dependent' in this sense means the object is dependent on another object for its existence in a DB"

	^self object
]
