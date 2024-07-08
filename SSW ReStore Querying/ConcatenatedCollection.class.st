"
ReStore
©2019 John Aspinall
https://github.com/rko281/ReStore
"
Class {
	#name : 'ConcatenatedCollection',
	#superclass : 'OrderedCollection',
	#type : 'variable',
	#category : 'SSW ReStore Querying',
	#package : 'SSW ReStore Querying'
}

{ #category : 'double dispatch' }
ConcatenatedCollection >> concatenatedWith: aConcatenatedCollection [

	^aConcatenatedCollection 
		addAllLast: self; 
		yourself
]

{ #category : 'operations' }
ConcatenatedCollection >> || anObject [

	^anObject concatenatedWith: self
]
