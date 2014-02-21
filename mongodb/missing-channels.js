var channelHash = {};
db.images.find().forEach(function (image) {
	image.tags.forEach(function (tag) {
		channelHash[tag.channel.toString()] = {
			id: tag.channel
		};
	});
});

var channelIds = Object.keys(channelHash).map(function (key) {
	return channelHash[key].id;
});
channelIds.forEach(function (id) {
	var channel = db.channels.findOne({_id:id});
	var query = {'tags.channel':id};
	var update = {
		$pull: { tags: {channel:id} }
	};
	if (!channel) {
		printjson(update);
		db.images.update(query, update, {multi:true})
	}
});