$(function() {
	$('.CodeMirror').after(
				function (x) {
					var btn = $("<button>Uruchom</button>");
					var where = $(this);
					var resId =  "results-"+where.prev().attr('id')
					btn.click(function() {
						$("#"+resId).fadeOut();
						var paramsN = { file: window[$(this).prev().prevAll("textarea").attr('id')].getValue()};
						var maybeFile =  $(this).prev().prevAll("textarea").attr('attach-file');
						if (maybeFile) {
							paramsN['addition'] = window[maybeFile];
						}
						$.post("http://localhost:8000", paramsN, //{
//							file: window[$(this).prev().prevAll("textarea").attr('id')].getValue()
//						}, 
						function(data, text, whatever) {
							var res = $("<pre></pre>");
							var numFst = data.indexOf("\n");
							var code = data.substring(0, numFst);
							data = data.substring(numFst+1);
							if ((new RegExp("^ExitSuccess")).test(code)) {
								res.css("background", "PaleGreen");
							} else {
								res.css("background", "red");
							}
							res.css("display", "none");
							res.attr('id', resId);
							res.html(data);
							$("#"+resId).remove();
							where.after(res);
							res.fadeIn();
						});
						return false;
					});
					return btn;
				});
});

