"
ReStore
©2019 John Aspinall
https://github.com/rko281/ReStore
"
Class {
	#name : 'SSWDBSubTable',
	#superclass : 'SSWDBAbstractSubTable',
	#category : 'SSW ReStore Tables',
	#package : 'SSW ReStore Tables'
}

{ #category : 'evaluating' }
SSWDBSubTable >> withAllFields [

	"Return a table equivalent to the receiver but containing all possible fields.	
	For a subtable (not inherited further) can optimise this back to just the receiver"

	^self
]
