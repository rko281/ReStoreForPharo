Extension { #name : #Time }

{ #category : #'*SSW ReStore Base Additions' }
Time >> withResolution: anInteger [

	"Return a copy of the receiver with the resolution (number of fractional digits) anInteger, i.e. 0 for seconds resolution, 3 for milliseconds etc."

	| multiplier |

	multiplier := 10 ** anInteger.

	^Time fromSeconds: ((seconds * multiplier) rounded / multiplier)
]
