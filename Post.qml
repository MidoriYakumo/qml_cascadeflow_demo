import QtQuick 2.0

Item {
	id: root
	width: 200
	height: 0
	opacity: 0

	property int seed: Math.random()*1700 + 1

	//http://xkcd.com/1750/

	Image {
		id: img
		anchors.fill: parent
		asynchronous: true
		onSourceSizeChanged: {
			root.height = sourceSize.height*root.width/sourceSize.width
			root.opacity = 1
		}
	}

	Behavior on opacity {
		NumberAnimation {
			duration: 400
		}
	}

	Component.onCompleted: {
		var xhr = new XMLHttpRequest();
		xhr.onreadystatechange = function() {
			if (xhr.readyState === XMLHttpRequest.DONE && xhr.status === 200) {
				var t = xhr.responseText
				var p = t.search("<div id=\"comic\">")
				t = t.slice(p)
				p = t.search("src=")
				t = t.slice(p+5)
				p = t.search('"')
				t = t.slice(0, p)
				img.source = "http:"+t
				console.log("http://xkcd.com/%1/".arg(root.seed))
				console.log("->" + img.source)
			}
		}

		xhr.open("GET", "http://xkcd.com/%1/".arg(root.seed))
		xhr.send()
	}
}
