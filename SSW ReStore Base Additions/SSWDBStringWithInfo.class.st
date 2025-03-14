"
ReStore
©2019 John Aspinall
https://github.com/rko281/ReStore
"
Class {
	#name : 'SSWDBStringWithInfo',
	#superclass : 'SSWDBClassWithInfo',
	#instVars : [
		'fieldSize'
	],
	#category : 'SSW ReStore Base Additions',
	#package : 'SSW ReStore Base Additions'
}

{ #category : 'instance creation' }
SSWDBStringWithInfo class >> instanceFromDBValue: aValue in: aReStore [

	^aValue
]

{ #category : 'accessing' }
SSWDBStringWithInfo >> fieldSize [

	"fieldSize stores the size of the field in which 'instances' of this 'class' will live.
	The definition of 'size' (i.e. max size or fixed size) is dependent on the subclass"

	^fieldSize
]

{ #category : 'accessing' }
SSWDBStringWithInfo >> fieldSize: anInteger [

	"fieldSize stores the size of the field in which 'instances' of this 'class' will live.
	The definition of 'size' (i.e. max size or fixed size) is dependent on the subclass"

	fieldSize := anInteger
]

{ #category : 'constants' }
SSWDBStringWithInfo >> infoClass [

	^String
]
