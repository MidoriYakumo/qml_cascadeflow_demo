import QtQuick 2.0
import QtGraphicalEffects 1.0

Item {
	width: 800
	height: 600

	Flickable {
		anchors.fill: parent
		flickableDirection: Flickable.VerticalFlick
		contentHeight: flow.height

		Item {
			id: flow
			anchors.top: parent.top
			height: parent.height
			anchors.horizontalCenter: parent.horizontalCenter
			width: columns * (cardWidth+spacing) - spacing
			anchors.margins: 8


			property int spacing: 8
			property int cardWidth: 160
			property int animeDuration: 400
			property int columns: (parent.width+spacing)/(cardWidth+spacing)
			property int length
			property var cards: []
			property var bottoms: []

			function update(item) {
				var upCard = bottoms[0]
				var column = 0
				var maxBY = upCard.bottomY
				for (var i = 1;i<columns;i++) {
					if (bottoms[i].bottomY<upCard.bottomY) {
						upCard = bottoms[i]
						column = i
					}
					if (bottoms[i].bottomY>maxBY)
						maxBY = bottoms[i].bottomY
				}

				flow.height = maxBY + anchors.margins
				item.upCard = upCard
				item.downCard = dummy
				upCard.downCard = item
				item.column = column
				bottoms[column] = item
			}

			function push(item) {
				cards.push(item)
				update(item)
				length = cards.length
			}

			function remove(idx) {
				var item = cards[idx]
				cards = cards.slice(0, idx).concat(cards.slice(idx+1))
				item.upCard.downCard = item.downCard
				item.downCard.upCard = item.upCard
				if (item === bottoms[item.column])
					bottoms[item.column] = item.upCard
				item.opacity = 0
				length = cards.length
			}

			Item {
				id: dummy
				property int bottomY: targetY+height
				property Item upCard: dummy
				property Item downCard: dummy
				property int targetY: 0
				x: 0
				y: targetY
				width: 0
				height: 0
			}

			Item {
				id: bottomy
				property int bottomY: targetY+height
				property Item upCard: dummy
				property Item downCard: dummy
				property int targetY: parent.height
				x: (parent.width-flow.cardWidth)/2
				y: targetY
				width: 0
				height: 0
			}

			Component {
				id: card

				Rectangle {
					property int bottomY: targetY+height
					property Item upCard: bottomy
					property Item downCard: bottomy
					property int column: flow.columns/2
					property int targetY: upCard.targetY + upCard.height + flow.spacing
					opacity: 0
					x: (width + flow.spacing)*column
					y: targetY
					width: flow.cardWidth
					height: 40 + Math.random()*80
					color: Qt.hsla(Math.random(), .7, .5, 1.)
					Behavior on x {
						NumberAnimation {
							duration: flow.animeDuration
						}
					}

					Behavior on y {
						NumberAnimation {
							duration: flow.animeDuration
						}
					}

					Behavior on opacity {
						NumberAnimation {
							duration: flow.animeDuration
						}
					}

					onOpacityChanged: {
						if (opacity <=0)
							destroy()
					}

					Component.onCompleted: {
						opacity = 1
					}

					layer.enabled: true
					layer.effect: Glow {
						color: Qt.rgba(0,0,0,.3*parent.opacity)
						radius: 3
						spread: 0.3
					}
				}
			}

			onColumnsChanged: {
				var i
				bottoms = []
				for (i=0;i<columns;i++)
					bottoms.push(dummy)
				for (i=0;i<cards.length;i++)
					update(cards[i])
			}
            
            Behavior on height {
				NumberAnimation {
					duration: flow.animeDuration
				}
			}
		}
	}

	Timer {
		repeat: true
		interval: flow.animeDuration * 2
		running: true
		triggeredOnStart: true

		onTriggered: {
			var r = Math.random()
			if (r>flow.length/(flow.columns*10)) {
				info.text = "Append to flow at %1".arg(flow.length)
				var ci = card.createObject(flow)
				var pi = post.createObject(flow)
				pi.parent = ci
				flow.push(ci)
			}
			else {
				r = Math.random()
				r = parseInt(r*flow.length)
				info.text = "Remove from flow at %1".arg(r)
				flow.remove(r)
			}
		}
	}

	Component {
		id: post

		Post {
			width: flow.cardWidth
			onHeightChanged: {
				if (parent)
					parent.height = height + 2
				else
					destroy()
			}
		}
	}

	Text {
		id: info
		x: 8
		y: parent.height - font.pixelSize - 8
	}
}
