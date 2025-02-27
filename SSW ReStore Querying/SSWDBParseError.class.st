"
ReStore
©2019 John Aspinall
https://github.com/rko281/ReStore
"
Class {
	#name : 'SSWDBParseError',
	#superclass : 'Error',
	#category : 'SSW ReStore Querying',
	#package : 'SSW ReStore Querying'
}

{ #category : 'testing' }
SSWDBParseError >> isFinalFieldError [

	^self tag = #finalField
]

{ #category : 'testing' }
SSWDBParseError >> isResumable [

	^self isFinalFieldError
]
