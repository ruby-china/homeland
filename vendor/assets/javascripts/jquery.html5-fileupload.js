/*
 *  jQuery HTML5 File Upload
 *  
 *  Author: timdream at gmail.com
 *  Web: http://timc.idv.tw/html5-file-upload/
 *  
 *  Ajax File Upload that use real xhr,
 *  built with getAsBinary, sendAsBinary, FormData, FileReader, ArrayBuffer, BlobBuilder and etc.
 *  works in Firefox 3, Chrome 5, Safari 5 and higher
 *
 *  Image resizing and uploading currently works in Fx 3 and up, and Chrome 9 (dev) and up only.
 *  Extra settings will allow current Webkit users to upload the original image
 *  or send the resized image in base64 form.
 *
 *  Usage:
 *   $.fileUploadSupported // a boolean value indicates if the browser is supported.
 *   $.imageUploadSupported // a boolean value indicates if the browser could resize image and upload in binary form.
 *   $.fileUploadAsBase64Supported // a boolean value indicate if the browser upload files in based64.
 *   $.imageUploadAsBase64Supported // a boolean value indicate if the browser could resize image and upload in based64.
 *   $('input[type=file]').fileUpload(ajaxSettings); //Make a input[type=file] select-and-send file upload widget
 *   $('#any-element').fileUpload(ajaxSettings); //Make a element receive dropped file
 *   //TBD $('form#fileupload').fileUpload(ajaxSettings); //Send a ajax form with file
 *   //TBD $('canvas').fileUpload(ajaxSettings); //Upload given canvas as if it's an png image.
 *
 *   ajaxSettings is the object contains $.ajax settings that will be passed to.
 *   Available extended settings are:
 *      fileType:
 *           regexp check against filename extension; You should always checked it again on server-side.
 *           e.g. /^(gif|jpe?g|png|tiff?)$/i for images
 *      fileMaxSize:
 *           Maxium file size allowed in bytes. Use scientific notation for converience.
 *           e.g. 1E4 for 1KB, 1E8 for 1MB, 1E9 for 10MB.
 *			 If you really care the difference between 1024 and 1000, use Math.pow(2, 10)
 *      fileError(info, textStatus, textDescription):
 *           callback function when there is any error preventing file upload to start,
 *           $.ajax and ajax events won't be called when error.
 *           Use $.noop to overwrite default alert function.
 *      imageMaxWidth, imageMaxHeight:
 *           Use any of the two settings to enable client-size image resizing.
 *           Image will be resized to fit into given rectangle.
 *           File size and type limit checking will be ignored.
 *      allowUploadOriginalImage:
 *           Set to true if you accept original image to be uploaded as a fallback
 *           when image resizing functionality is not availible (such as Webkit browsers).
 *           File size and type limit will be enforced.
 *      allowDataInBase64:
 *           Alternatively, you may wish to resize the image anyway and send the data
 *           in base64. The data will be 133% larger and you will need to process it further with 
 *           server-side script.
 *           This setting might work with browsers which could read file but cannot send it in original
 *           binary (no known browser are designed this way though)
 *      forceResize:
 *           Set to true will cause the image being re-sampled even if the resized image 
 *           has the same demension as the original one.
 *      imageType:
 *           Acceptable values are: 'jpeg', 'png', or 'auto'.
 *
 *  TBD: 
 *   ability to change settings after binding (you can unbind and bind again as a workaround)
 *   multipole file handling
 *   form intergation
 *
 */

(function($) {
	// Don't do logging if window.log function does not exist.
	var log = window.log || $.noop;

	// jQuery.ajax config
	var config = {
		fileError: function (info, textStatus, textDescription) {
			window.alert(textDescription);
		}
	};
	
	// Feature detection
	
	// Read as binary string: FileReader API || Gecko-specific function (Fx3)
	var canReadAsBinaryString = (window.FileReader || window.File.prototype.getAsBinary);
	// Read file using FormData interface
	var canReadFormData = !!(window.FormData);
	// Read file into data: URL: FileReader API || Gecko-specific function (Fx3)
	var canReadAsBase64 = (window.FileReader || window.File.prototype.getAsDataURL);

	var canResizeImageToBase64 = !!(document.createElement('canvas').toDataURL);
	var canResizeImageToBinaryString = canResizeImageToBase64 && window.atob;
	var canResizeImageToFile = !!(document.createElement('canvas').mozGetAsFile);
 	
	// Send file in multipart/form-data with binary xhr (Gecko-specific function)
	// || xhr.send(blob) that sends blob made with ArrayBuffer.
	var canSendBinaryString = (
		(window.XMLHttpRequest && window.XMLHttpRequest.prototype.sendAsBinary)
		|| (window.ArrayBuffer && window.BlobBuilder)
	);
	// Send file as in FormData object
	var canSendFormData = !!(window.FormData);
	// Send image base64 data by extracting data: URL
	var canSendImageInBase64 = !!(document.createElement('canvas').toDataURL);

	var isSupported = (
		(canReadAsBinaryString && canSendBinaryString)
		|| (canReadFormData && canSendFormData)
	);
	var isImageSupported = (
		canReadAsBase64 && (
			(canResizeImageToBinaryString && canSendBinaryString)
			|| (canResizeImageToFile && canSendFormData)
		)
	);
	var isSupportedInBase64 = canReadAsBase64;	
	var isImageSupportedInBase64 = canReadAsBase64 && canResizeImageToBase64;

	var dataURLtoBase64 = function (dataurl) {
		return dataurl.substring(dataurl.indexOf(',')+1, dataurl.length);
	}
	
	// Step 1: check file info and attempt to read the file
	// paramaters: Ajax settings, File object
	var handleFile = function (settings, file) {
		var info = {
			// properties of standard File object || Gecko 1.9 properties
			type: file.type || '', // MIME type
			size: file.size || file.fileSize,
			name: file.name || file.fileName
		};

		settings.resizeImage = !!(settings.imageMaxWidth || settings.imageMaxHeight);

		if (settings.resizeImage && !isImageSupported && settings.allowUploadOriginalImage) {
			log('WARN: Fall back to upload original un-resized image.');
			settings.resizeImage = false;
		}
		
		if (settings.resizeImage) {
			settings.imageMaxWidth = settings.imageMaxWidth || Infinity;
			settings.imageMaxHeight = settings.imageMaxHeight || Infinity;
		}

		if (!settings.resizeImage) {
			if (settings.fileType && settings.fileType.test) {
				// Not using MIME types
				if (!settings.fileType.test(info.name.substr(info.name.lastIndexOf('.')+1))) {
					log('ERROR: Invalid Filetype.');
					settings.fileError.call(this, info, 'INVALID_FILETYPE', 'Invalid filetype.');
					return;
				}
			}
			
			if (settings.fileMaxSize && file.size > settings.fileMaxSize) {
				log('ERROR: File exceeds size limit.');
				settings.fileError.call(this, info, 'FILE_EXCEEDS_SIZE_LIMIT', 'File exceeds size limit.');
				return;
			}
		}

		if (!settings.resizeImage && canReadFormData) {
			log('INFO: Bypass file reading, insert file object into FormData object directly.');
			handleForm(settings, 'file', file, info);
		} else if (window.FileReader) {
			log('INFO: Using FileReader to do asynchronously file reading.');
			var reader = new FileReader();
			reader.onerror = function (ev) {
				if (ev.target.error) {
					switch (ev.target.error) {
						case 8:
						log('ERROR: File not found.');
						settings.fileError.call(this, info, 'FILE_NOT_FOUND', 'File not found.');
						break;
						case 24:
						log('ERROR: File not readable.');
						settings.fileError.call(this, info, 'IO_ERROR', 'File not readable.');
						break;
						case 18:
						log('ERROR: File cannot be access due to security constrant.');
						settings.fileError.call(this, info, 'SECURITY_ERROR', 'File cannot be access due to security constrant.');
						break;
						case 20: //User Abort
						break;
					}
				}
			}
			if (!settings.resizeImage) {
				if (canSendBinaryString) {
					reader.onloadend = function (ev) {
						var bin = ev.target.result;
						handleForm(settings, 'bin', bin, info);
					};
					reader.readAsBinaryString(file);
				} else if (settings.allowDataInBase64) {
					reader.onloadend = function (ev) {
						handleForm(
							settings,
							'base64',
							dataURLtoBase64(ev.target.result),
							info
						);
					};
					reader.readAsDataURL(file);
				} else {
					log('ERROR: No available method to extract file; allowDataInBase64 not set.');
					settings.fileError.call(this, info, 'NO_BIN_SUPPORT_AND_BASE64_NOT_SET', 'No available method to extract file; allowDataInBase64 not set.');
				}
			} else {
				reader.onloadend = function (ev) {
					var dataurl = ev.target.result;
					handleImage(settings, dataurl, info);
				};
				reader.readAsDataURL(file);
			}
		} else if (window.File.prototype.getAsBinary) {
			log('WARN: FileReader does not exist, UI will be blocked when reading big file.');
			if (!settings.resizeImage) {
				try {
					var bin = file.getAsBinary();
				} catch (e) {
					log('ERROR: File not readable.');
					settings.fileError.call(this, info, 'IO_ERROR', 'File not readable.');
					return;
				}
				handleForm(settings, 'bin', bin, info);
			} else {
				try {
					var bin = file.getAsDataURL();
				} catch (e) {
					log('ERROR: File not readable.');
					settings.fileError.call(this, info, 'IO_ERROR', 'File not readable.');
					return;
				}
				handleImage(settings, dataurl, info);
			}
		} else {
			log('ERROR: No available method to extract file; this browser is not supported.');
			settings.fileError.call(this, info, 'NOT_SUPPORT', 'ERROR: No available method to extract file; this browser is not supported.');
		}
	};

	// step 1.5: inject file into <img>, paste the pixels into <canvas>,
	// read the final image
	var handleImage = function (settings, dataurl, info) {
		var img = new Image();
		img.onerror = function () {
			log('ERROR: <img> failed to load, file is not a supported image format.');
			settings.fileError.call(this, info, 'FILE_NOT_IMAGE', 'File is not a supported image format.');
		};
		img.onload = function () {
			var ratio = Math.max(
				img.width/settings.imageMaxWidth,
				img.height/settings.imageMaxHeight,
				1
			);
			var d = {
				w: Math.floor(Math.max(img.width/ratio, 1)),
				h: Math.floor(Math.max(img.height/ratio, 1))
			}
			log(
				'INFO: Original image size: ' + img.width.toString(10) + 'x' + img.height.toString(10)
				+ ', resized image size: ' + d.w + 'x' + d.h + '.'
			);
			if (!settings.forceResize && img.width === d.w && img.height === d.h) {
				log('INFO: Image demension is the same, send the original file.');
				if (canResizeImageToBinaryString) {
					handleForm(
						settings,
						'bin',
						window.atob(dataURLtoBase64(dataurl)),
						info
					);
				} else if (settings.allowDataInBase64) {
					handleForm(
						settings,
						'base64',
						dataURLtoBase64(dataurl),
						info
					);
				} else {
					log('ERROR: No available method to send the original file; allowDataInBase64 not set.');
					settings.fileError.call(this, info, 'NO_BIN_SUPPORT_AND_BASE64_NOT_SET', 'No available method to extract file; allowDataInBase64 not set.');
				}
				return;
			}
			var canvas = document.createElement('canvas');
			canvas.setAttribute('width', d.w);
			canvas.setAttribute('height', d.h);
			canvas.getContext('2d').drawImage(
				img,
				0,
				0,
				img.width,
				img.height,
				0,
				0, 
				d.w,
				d.h
			);
			if (!settings.imageType || settings.imageType === 'auto') {
				if (info.type === 'image/jpeg') settings.imageType = 'jpeg';
				else settings.imageType = 'png';
			}
			
			var ninfo = {
				type: 'image/' + settings.imageType,
				name: info.name.substr(0, info.name.indexOf('.')) + '.resized.' + settings.imageType
			};
			
			if (canResizeImageToFile && canSendFormData) {
				// Gecko 2 (Fx4) non-standard function
				var nfile = canvas.mozGetAsFile(
					ninfo.name,
					'image/' + settings.imageType
				);
				ninfo.size = file.size || file.fileSize;
				handleForm(
					settings,
					'file',
					nfile,
					ninfo
				);
			} else if (canResizeImageToBinaryString && canSendBinaryString) {
				// Read the image as DataURL, convert it back to binary string.
				var bin = window.atob(dataURLtoBase64(canvas.toDataURL('image/' + settings.imageType)));
				ninfo.size = bin.length;
				handleForm(
					settings,
					'bin',
					bin,
					ninfo
				);
			} else if (settings.allowDataInBase64 && canResizeImageToBase64 && canSendImageInBase64) {
				handleForm(
					settings,
					'base64',
					dataURLtoBase64(canvas.toDataURL('image/' + settings.imageType)),
					ninfo
				);
			} else {
				log('ERROR: No available method to extract image; allowDataInBase64 not set.');
				settings.fileError.call(this, info, 'NO_BIN_SUPPORT_AND_BASE64_NOT_SET', 'No available method to extract file; allowDataInBase64 not set.');
			}
		}
		img.src = dataurl;
	}
	// Step 2: construct form data and send the file
	// paramaters: Ajax settings, File object, binary string of file || null, file info assoc array
	var handleForm = function (settings, type, data, info) {
		if (canSendFormData && type === 'file') {
			// FormData API saves the day
			log('INFO: Using FormData to construct form.');
			var formdata = new FormData();
			formdata.append('Filedata', data);
			// Prevent jQuery form convert FormData object into string.
			settings.processData = false;
			// Prevent jQuery from overwrite automatically generated xhr content-Type header
			// by unsetting the default contentType and inject data only right before xhr.send()
			settings.contentType = null;
			settings.__beforeSend = settings.beforeSend;
			settings.beforeSend = function (xhr, s) {
				s.data = formdata;
				if (s.__beforeSend) return s.__beforeSend.call(this, xhr, s);
			}
			//settings.data = formdata;
		} else if (canSendBinaryString && type === 'bin') {
			log('INFO: Concat our own multipart/form-data data string.');
						
			// A placeholder MIME type
			if (!info.type) info.type = 'application/octet-stream';

			if (/[^\x20-\x7E]/.test(info.name)) {
				log('INFO: Filename contains non-ASCII code, do UTF8-binary string conversion.');
				info.name_bin = unescape(encodeURIComponent(info.name));
			}
			
			//filtered out non-ASCII chars in filenames
			// info.name = info.name.replace(/[^\x20-\x7E]/g, '_');
			
			// multipart/form-data boundary
			var bd = 'xhrupload-' + parseInt(Math.random()*(2 << 16));
			settings.contentType = 'multipart/form-data; boundary=' + bd;
			var formdata = '--' + bd + '\n' // RFC 1867 Format, simulate form file upload
			+ 'content-disposition: form-data; name="Filedata";'
			+ ' filename="' + (info.name_bin || info.name) + '"\n'
			+ 'Content-Type: ' + info.type + '\n\n'
			+ data + '\n\n'
			+ '--' + bd + '--';
			
			if (window.XMLHttpRequest.prototype.sendAsBinary) {
				// Use xhr.sendAsBinary that takes binary string
				log('INFO: Pass binary string to xhr.');
				settings.data = formdata;
			} else {
				// make a blob
				log('INFO: Convert binary string into Blob.');
				var buf = new ArrayBuffer(formdata.length);
				var view = new Uint8Array(buf);
				$.each(
					formdata,
					function (i, o) {
						view[i] = o.charCodeAt(0);
					}
				);
				var bb = new BlobBuilder();
				bb.append(buf);
				var blob = bb.getBlob();
				
				settings.processData = false;
				settings.__beforeSend = settings.beforeSend;
				settings.beforeSend = function (xhr, s) {
					s.data = blob;
					if (s.__beforeSend) return s.__beforeSend.call(this, xhr, s);
				};
			}
			
		} else if (settings.allowDataInBase64 && type === 'base64') {
			log('INFO: Concat our own multipart/form-data data string; send the file in base64 because binary xhr is not supported.');
			
			// A placeholder MIME type
			if (!info.type) info.type = 'application/octet-stream';

			// multipart/form-data boundary
			var bd = 'xhrupload-' + parseInt(Math.random()*(2 << 16));
			settings.contentType = 'multipart/form-data; boundary=' + bd;
			settings.data = '--' + bd + '\n' // RFC 1867 Format, simulate form file upload
			+ 'content-disposition: form-data; name="Filedata";'
			+ ' filename="' + encodeURIComponent(info.name) + '.base64"\n'
			+ 'Content-Transfer-Encoding: base64\n' // Vaild MIME header, but won't work with PHP file upload handling.
			+ 'Content-Type: ' + info.type + '\n\n'
			+ data + '\n\n'
			+ '--' + bd + '--';
		} else {
			log('ERROR: Data is not given in processable form.');
			settings.fileError.call(this, info, 'INTERNAL_ERROR', 'Data is not given in processable form.');
			return;
		}
		xhrupload(settings);
	};

	// Step 3: start sending out file
	var xhrupload = function (settings) {
		log('INFO: Sending file.');
		if (typeof settings.data === 'string' && canSendBinaryString) {
			log('INFO: Using xhr.sendAsBinary.');
			settings.___beforeSend = settings.beforeSend;
			settings.beforeSend = function (xhr, s) {
				xhr.send = xhr.sendAsBinary;
				if (s.___beforeSend) return s.___beforeSend.call(this, xhr, s);
			}
		}
		$.ajax(settings);
	};
	
	$.fn.fileUpload = function(settings) {
		this.each(function(i, el) {
			if ($(el).is('input[type=file]')) {
				log('INFO: binding onchange event to a input[type=file].');
				$(el).bind(
					'change',
					function () {
						if (!this.files.length) {
							log('ERROR: no file selected.');
							return;
						} else if (this.files.length > 1) {
							log('WARN: Multiple file upload not implemented yet, only first file will be uploaded.');
						}
						handleFile($.extend({}, config, settings), this.files[0]);
						
						if (this.form.length === 1) {
							this.form.reset();
						} else {
							log('WARN: Unable to reset file selection, upload won\'t be triggered again if user selects the same file.');
						}
						return;
					}
				);
			}
			
			if ($(el).is('form')) {
				log('ERROR: <form> not implemented yet.');
			} else {
				log('INFO: binding ondrop event.');
				$(el).bind(
					'dragover', // dragover behavior should be blocked for drop to invoke.
					function(ev) {
						return false;
					}
				).bind(
					'drop',
					function (ev) {
						if (!ev.originalEvent.dataTransfer.files) {
							log('ERROR: No FileList object present; user might had dropped text.');
							return false;
						}
						if (!ev.originalEvent.dataTransfer.files.length) {
							log('ERROR: User had dropped a virual file (e.g. "My Computer")');
							return false;
						}
						if (!ev.originalEvent.dataTransfer.files.length > 1) {
							log('WARN: Multiple file upload not implemented yet, only first file will be uploaded.');
						}
						handleFile($.extend({}, config, settings), ev.originalEvent.dataTransfer.files[0]);
						return false;
					}
				);
			}
		});

		return this;
	};
	
	$.fileUploadSupported = isSupported;
	$.imageUploadSupported = isImageSupported;
	$.fileUploadAsBase64Supported = isSupportedInBase64;
	$.imageUploadAsBase64Supported = isImageSupportedInBase64;
	
})(jQuery);
