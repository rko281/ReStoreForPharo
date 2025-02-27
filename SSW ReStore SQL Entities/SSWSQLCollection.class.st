"
ReStore
©2019 John Aspinall
https://github.com/rko281/ReStore
"
Class {
	#name : 'SSWSQLCollection',
	#superclass : 'OrderedCollection',
	#type : 'variable',
	#category : 'SSW ReStore SQL Entities',
	#package : 'SSW ReStore SQL Entities'
}

{ #category : 'converting' }
SSWSQLCollection >> asOrderedCollection [
	"Answer an OrderedCollection containing the same elements as the receiver.
	The elements of the OrderedCollection will be sorted (at least initially) in the
	sort order of the receiver.
	Implementation Note: Revert to the Collection implementation."

	^(OrderedCollection new: self size)
		addAll: self;
		yourself
]

{ #category : 'testing' }
SSWSQLCollection >> isFieldCollection [

	^false
]

{ #category : 'output' }
SSWSQLCollection >> sqlConcatenator [

	"Return the String that concatenates the list of SQL entities held by the receiver
	(this should also contain any required whitespace characters)"
	
	^self subclassResponsibility
]

{ #category : 'output' }
SSWSQLCollection >> writeSQLOn: aStream [

	self isEmpty ifTrue: [^self].

	self do: [ :condition | condition writeSQLOn: aStream] separatedBy: [aStream nextPutAll: self sqlConcatenator]
]
