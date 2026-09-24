Extension { #name : 'Time' }

{ #category : '*SSW ReStore Base Additions' }
Time class >> readFromNegativeTolerant: aStream [

	"Read a Time from aStream.
	The contained value may be negative if it represents e.g. an offset from UTC.
	In this case answer a Duration"

	| isNegative time |

	(isNegative := aStream peek = $-) ifTrue: [aStream next].
	time := self readFrom: aStream.

	^isNegative 
		ifTrue: [Duration seconds: time asSeconds negated]
		ifFalse: [time]
]
