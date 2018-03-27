/*=================================================================================================
 This script provides functionality to add and remove documents from a user's bookbag.

 It assumes that all bookbag links have a common CSS selector, as well as an attribute that uniquely
 identifies a document. It also assumes that the element displaying the number of items in a bookbag
 has a unique CSS selector. These values are controlled by variables:

 bookbag - the CSS selector for all bookbag links.
 bagCount - the element which displays the number of items in the bookbag.
 ================================================================================================ */

var bookbagInitializer = function () {
    // Sets global selector variables
    var listAdd = '.list-add';
    var listDelete = '.list-delete';
    var listCount = '.listCount';

    // Removes link and changes text displayed if cookies are not enabled
    if (!navigator.cookieEnabled) {
        $(listAdd).text('Cookies not enabled');
    };

    function setAeonButtonStateEnabled(enabled)
    {
        $('.request-copies').prop('disabled',!enabled);
        $('.request-room').prop('disabled',!enabled);
        $('.review').prop('disabled',!enabled);
        $('.remove-all').prop('disabled',!enabled);
    }
    //gets list items from localStorage
    function getList() {
        if (localStorage.getItem("myList")) {
            var list = JSON.parse(localStorage.getItem("myList")).sort();
            return list;
        } else {
            return null;
        }
    };

    function removeFromAeonList(element)
    {
        var a = $(element);
        var identifier = $(a).attr('data-identifier');
        var myList = getList();

        for (var i = 0; i <= myList.length - 1; i++) {
            var item = myList[i];
            if (item.identifier === identifier) {
                myList.splice(i, 1);
                // change text for components already in book bag
                $('.list-added[data-identifier="' + identifier + '"]').replaceWith(item.originalButton);
                $('.list-add[data-identifier="' + identifier + '"]').on('click', addToList);

            }
        }

        // save new list in localStorage
        saveList(myList);

        // update display
        updateDisplay();
    }
    //saves list items to localStorage
    function saveList(collection) {
        localStorage.setItem("myList", JSON.stringify(collection));
    };

    //update list on bookbag page and in dialogs
    function updateDisplay() {
        var myList = getList();
        if (myList) {
            $('.myListContents').empty();
            if (myList.length > 0) {
                $('#myListNav #myListButton').addClass('hasContents');
                $('.myListContents').append(
                        '<div class="aeon-row header-row">' +
                        '<div class="requestInputs"><input type="checkbox" checked="checked" name="allRequests"/></div>' +
                        '<div class="collectionTitle">Title/Collection title</div>' +
                        '<div class="title">Item Title</div>' +
                        '<div class="CallNumber">Call Number</div>' +
                        '<div class="volume">Volume / Box</div>' +
                        '</div>');

                $('.header-row input[type="checkbox"]').on('click', function (e) {
                    if ($(this).is(':checked')) {
                        $('.requestInputs input[type="checkbox"]').attr('checked', true);
                        $('.requestInputs input[type="hidden"]').attr("disabled", false);
                        setAeonButtonStateEnabled(true);
                        if(!($(this).parents('.myListContents').hasClass('dialog'))) {
                            $('.requestInputs').parents('.aeon-row:not(.header-row)').removeClass('disabled');
                        }

                    } else {
                        $('.requestInputs input[type="checkbox"]').attr('checked', false);
                        $('.requestInputs input[type="hidden"]').attr("disabled", true);
                        setAeonButtonStateEnabled(false);
                        if(!($(this).parents('.myListContents').hasClass('dialog'))) {
                            $('.requestInputs').parents('.aeon-row:not(.header-row)').addClass('disabled');
                        }
                    }
                    var listCount = $('#listContentForm .aeon-row > .requestInputs > input[checked="checked"]').length - 1;
                    $('.listCount').html(listCount < 0 ? 0 : listCount);

                });

            }

            var form_data = '';

            for (var i = 0; i <= myList.length - 1; i++) {
                var item = myList[i];

                //create variables
                function sanitize(value) {
                    if (value) {
                        return value;
                    }
                    else {
                        return '';
                    }
                };

                function dateConvert(value) {
                    if (value) {
                        var date = new Date(value);
                        var d = date.toDateString();
                        var h = date.getHours();
                        var m = date.getMinutes();
                        if (h > 12) {
                            var p = h - 12;
                            return d + ', ' + p + ':' + m + ' pm';
                        } else {
                            return d + ', ' + h + ':' + m + ' am';
                        }
                    } else {
                        return '';
                    }
                };

                function containerJoin(container1, container2) {
                    if (container1) {
                        if (container2) {
                            return container1 + ', ' + container2;
                        } else {
                            return container1
                        }
                    } else {
                        return '';
                    }
                    e.preventDefault();
                };

                function splitparents(string) {
                    if (string) {
                        var split = string.split('; ');
                        var parents = '';
                        for (var i = 0; i < split.length; i++) {
                            var parent = '<div style="text-indent:' + i * 2 + 'px;">' + split[i] + '</div>'
                            parents = parents + parent;
                        }
                        ;
                        return parents;
                    } else {
                        return '';
                    }
                };


                var template = '<div class="aeon-row"><div class="requestInputs"><input type="checkbox" checked="checked" name="Request" value="{{identifier}}"/><input type="hidden" name="ReferenceNumber_{{identifier}}" value="{{referenceNumber}}"/><input type="hidden" name="ItemNumber_{{identifier}}" value="{{itemNumber}}"/><input type="hidden" name="Site_{{identifier}}" value="{{site}}"/><input type="hidden" name="ItemTitle_{{identifier}}" value="{{title}}"/><input type="hidden" name="ItemSubtitle_{{identifier}}" value="{{subTitle}}"/><input type="hidden" name="ItemInfo1_{{identifier}}" value="{{itemInfo1}}"/><input type="hidden" name="ItemInfo2_{{identifier}}" value="{{itemInfo2}}"/><input type="hidden" name="ItemInfo3_{{identifier}}" value="{{itemInfo3}}"/><input type="hidden" name="Author_{{identifier}}" value="{{itemAuthor}}"/><input type="hidden" name="ItemAuthor_{{identifier}}" value="{{itemAuthor}}"/><input type="hidden" name="ItemDate_{{identifier}}" value="{{itemDate}}"/><input type="hidden" name="CallNumber_{{identifier}}" value="{{callNumber}}"/><input type="hidden" name="ItemVolume_{{identifier}}" value="{{itemVolume}}"/></div><div class="collectionTitle"><p>{{title}}</p></div><div class="title"><p>{{subTitle}}</p></div><div class="CallNumber"><p>{{callNumber}}</p></div><div class="volume"><p>{{itemVolume}}</p></div><button class="list-delete btn btn-default" href="#" data-identifier="{{identifier}}">Delete</button></div>'
                var aeon_item = {
                    identifier: sanitize(item.identifier),
                    referenceNumber: sanitize(item.referenceNumber),
                    itemNumber: sanitize(item.itemNumber),
                    site: sanitize(item.site),
                    title: sanitize(item.title),
                    subTitle: sanitize(item.subTitle),
                    itemInfo1: sanitize(item.itemInfo1),
                    itemInfo2: sanitize(item.itemInfo2),
                    itemInfo3: sanitize(item.itemInfo3),
                    itemAuthor: sanitize(item.itemAuthor),
                    itemDate: sanitize(item.itemDate),
                    callNumber: sanitize(item.callNumber),
                    itemVolume: sanitize(item.itemVolume)

                };
                form_data += Mustache.to_html(template, aeon_item);


                // change text for components already in bookbag
                $('.list-add[data-identifier="' + item.identifier + '"]').replaceWith('<span class="list-added" data-identifier="' + item.identifier + '">Added to List</span>');

            }
            ;

            //Attempting to append the html outside the for loop as there would be an occasional failure to append that seemed to be due to a
            //browser race condition in the DOM
            $('.myListContents').append(form_data);
            // update list count
            var count = myList.length
            $(listCount).text(count);
            if (count === 1) {
                $('.listCountText').text(' Item')
            } else {
                $('.listCountText').text(' Items')
            }


            if (count < 1) {
                $('.myListContents').append('<div class="empty">Your List is empty! Click on the icon that looks like this <span class="glyphicon glyphicon-plus-sign"></span></i> to add it to your list.</div>');
                $('#myListNav #myListButton').removeClass('hasContents');
                $('.listActions').hide();
            }

            if (count >= 1) {
                $('.listActions').show();

            }

            $('.aeon-row:not(.header-row) input[type="checkbox"]').on('click', function (e) {
                if ($(this).is(':checked')) {
                    $(this).closest('.requestInputs input[type="checkbox"]').attr('checked', true);
                    $(this).closest('.aeon-row').removeClass('disabled');
                    $(this).siblings().attr("disabled", false);

                    var listCount = $('#listContentForm .aeon-row:not(.header-row) > .requestInputs > input[checked="checked"]').length;
                    $('.listCount').html(listCount < 0 ? 0 : listCount);


                } else {
                    $(this).closest('.requestInputs input[type="checkbox"]').attr('checked', false);
                    $(this).closest('.aeon-row').addClass('disabled');
                    $(this).siblings().attr("disabled", true);

                    var listCount = $('#listContentForm .aeon-row:not(.header-row) > .requestInputs > input[checked="checked"]').length;
                    $('.listCount').html(listCount < 0 ? 0 : listCount);
                }
                if (listCount < 1)
                {
                    setAeonButtonStateEnabled(false);
                }
                else
                {
                    setAeonButtonStateEnabled(true);
                }
            });


        } else {
            //if list is empty, set count to zero
            $(listCount).text('0');
            $('.myListContents').append('<div class="empty">Your List is empty! Click on the icon that looks like this <span class="glyphicon glyphicon-plus-sign"></span> to add it to your list.</div>');
            $('#myListNav #myListButton').removeClass('hasContents');
            $('.listActions').hide();
            $('#myListNav #myListButton').removeClass('hasContents');
        }


        return false;

    };

    function validate() {


        if ($('#myReproductionActions select[name="Format"]').val()) {
            $('#myReproductionActions select[name="Format"]').removeClass('error');
            $('#myReproductionActions #formatError').hide();
            if ($('#myReproductionActions input[name="ItemPages"]').val()) {
                if ($('#myReproductionActions input[name="ReadAgreement"]').is(':checked')) {
                    return true;
                }
                else {
                    $('#ReadAgreementLabel').addClass('error');
                    return false;
                }
            } else {
                $('#myReproductionActions input[name="ItemPages"]').addClass('error');
                $('#myReproductionActions #itemPagesError').show();

                if ($('#myReproductionActions input[name="ReadAgreement"]').is(':checked')) {
                    $('#ReadAgreementLabel').removeClass('error');
                } else {
                    $('#ReadAgreementLabel').addClass('error');

                }
                return false;
            }
        } else {
            $('#myReproductionActions select[name="Format"]').addClass('error');
            $('#myReproductionActions #formatError').show();
            if ($('#myReproductionActions input[name="ItemPages"]').val()) {
                $('#myReproductionActions input[name="ItemPages"]').removeClass('error');
                $('#myReproductionActions #itemPagesError').hide();

                if ($('#myReproductionActions input[name="ReadAgreement"]').is(':checked')) {
                    $('#ReadAgreementLabel').removeClass('error');
                } else {
                    $('#ReadAgreementLabel').addClass('error');

                }

                return false;
            } else {
                $('#myReproductionActions input[name="ItemPages"]').addClass('error');
                $('#myReproductionActions #itemPagesError').show();

                if ($('#myReproductionActions input[name="ReadAgreement"]').is(':checked')) {
                    $('#ReadAgreementLabel').removeClass('error');
                } else {
                    $('#ReadAgreementLabel').addClass('error');

                }

                return false;
            }
        }
        return true;
    }

    //Might need some functions to sort by various fields, maybe title, collection, creator, date added
    //function sortList(param) {}
    function addToList(e) {

        var a = $(this);

        //data variables
        var identifier = $(a).attr('data-identifier');
        var referenceNumber = $(a).attr('data-referencenumber');
        var itemNumber = $(a).attr('data-itemnumber');
        var site = $(a).attr('data-site');
        var title = $(a).attr('data-itemtitle');
        var subTitle = $(a).attr('data-itemsubtitle');
        var itemInfo1 = $(a).attr('data-iteminfo1');
        var itemInfo2 = $(a).attr('data-iteminfo2');
        var itemInfo3 = $(a).attr('data-iteminfo3');
        var itemAuthor = $(a).attr('data-itemauthor');
        var itemDate = $(a).attr('data-itemdate');
        var callNumber = $(a).attr('data-callnumber');
        var itemVolume = $(a).attr('data-itemvolume');
        var originalButton = $(a).prop('outerHTML');

        //Let the user know something is happpening
        var text = a.text();
        //a.text('Adding...');

        // Add document to myList in localStorage
        // figure out if there's an existing list in localStorage
        var localStorage = getList();
        if (localStorage) {
            var myList = localStorage;
        } else {
            var myList = new Array();
        }
        ;

        //create a new object to add to the array
        //var dateAdded = Date.now();
        var doc = {
            'identifier': identifier,
            'referenceNumber': referenceNumber,
            'itemNumber': itemNumber,
            'site': site,
            'title': title,
            'subTitle': subTitle,
            'itemInfo1': itemInfo1,
            'itemInfo2': itemInfo2,
            'itemInfo3': itemInfo3,
            'itemAuthor': itemAuthor,
            'itemDate': itemDate,
            'callNumber': callNumber,
            'itemVolume': itemVolume,
            'originalButton': originalButton
        }

        var identifier = $(a).attr('data-identifier');
        var referenceNumber = $(a).attr('data-referencenumber');
        var itemNumber = $(a).attr('data-itemnumber');
        var site = $(a).attr('data-site');
        var title = $(a).attr('data-itemtitle');
        var subTitle = $(a).attr('data-itemsubtitle');
        var itemInfo1 = $(a).attr('data-iteminfo1');
        var itemInfo2 = $(a).attr('data-iteminfo2');
        var itemInfo3 = $(a).attr('data-iteminfo3');
        var itemAuthor = $(a).attr('data-itemauthor');
        var itemDate = $(a).attr('data-itemdate');
        var callNumber = $(a).attr('data-callnumber');
        var itemVolume = $(a).attr('data-itemvolume');
        var originalButton = $(a).prop('outerHTML');

        //add the new item to the existing array
        myList.push(doc);

        //save the new list in localStorage
        saveList(myList);

        // update display
        updateDisplay();

        e.preventDefault();
        //  a.text(text);
        //need this so function doesn't run twice
        return false;
    }

    //Adds documents to My List
    $(listAdd).on('click', addToList);
    $('.back_button').on('click', function (e) {
        $('#myRequestActions').hide();
        $('#myReproductionActions').hide();
        $('#myReviewActions').hide();
        $('.myListContents').show();
        $('#requestActions').show();
        e.preventDefault();
    });
    // Removes documents from My List
    $('body').on('click', listDelete, function(e) {
        removeFromAeonList(this);
        e.preventDefault();
    });

    $('#myListActions').append('<div id="requestActions" class="listActions">' +
        '<button class="btn btn-default request-copies" href="#"><span class="glyphicon glyphicon-file"></span>&nbsp;Request Copies</button>' +
        '<button class="btn btn-default request-room" href="#"><span class="glyphicon glyphicon-book"></span></i>&nbsp;Request in Reading Room</button>' +
        '<button class="btn btn-default review" href="#"><span class="glyphicon glyphicon-upload"></span></i>&nbsp;Save in TASCR</button>' +
        '<button class="btn btn-default myListRemoveAll remove-all" href="#"><span class="glyphicon glyphicon-trash"></span>&nbsp;Remove all Items from List</button>' + '</div>');

    function moveCheckedItemsToRequestForm()
    {
        var checkedItems = $('#listContentForm .aeon-row:not(.header-row) > .requestInputs > input[checked="checked"]');
        $.each(checkedItems, function(index, value) {
            var element = $(value).parents('.aeon-row').detach();
            $('#requestForm').append(element.get(0));
        });
    }
    $('#reviewItemsButton').on('click', function (e) {
        $('input[name="UserReview"]').val("Yes");

        moveCheckedItemsToRequestForm();

        $("#requestForm").submit();
        $('#cart_modal').modal("hide");
        $('.back_button').click();
        $('#dialogMyListSaveConfirm').modal("show");


        e.preventDefault();
    });

    $('#dialogMyListRequestConfirm, #dialogMyListSaveConfirm').on('hidden', function () {
        // do something…
        var checkedItems = $('#requestForm > .aeon-row');
        $.each(checkedItems, function(index, value) {
            $(value).remove();
            removeFromAeonList($(value).closest('.aeon-row').find('.list-delete'));
        });
    });

    $("#requestItemsButton").on('click', function (e) {
        if ($('#myRequestActions input[name="ScheduledDate"]').val()) {
            $('input[name="UserReview"]').val("No");

            moveCheckedItemsToRequestForm();

            $("#requestForm").submit();
            $('#cart_modal').modal("hide");
            $('.back_button').click();
            $('#myRequestActions input[name="ScheduledDate"]').removeClass('error');
            $('#myRequestActions #dateError').hide();
            $('#dialogMyListRequestConfirm').modal("show");

            return true;
        } else {
            $('#myRequestActions input[name="ScheduledDate"]').addClass('error');
            $('#myRequestActions #dateError').show();

            return false;
        }
    });

    $("#requestReproductionButton").on('click', function (e) {
        if (validate()) {

            moveCheckedItemsToRequestForm();

            $("#requestForm").submit();
            $('.back_button').click();
            $('#myReproductionActions input[name="ItemPages"]').removeClass('error');
            $('#myReproductionActions #itemPagesError').hide();
            $('#myReproductionActions select[name="Format"]').removeClass('error');
            $('#myReproductionActions #formatError').hide();
            $('#cart_modal').modal("hide");
            $('#dialogMyListRequestConfirm').modal("show");

            return true;
        } else {
            return false;
        }

    });

    $('.review').on('click', function (e) {
        $('.myListContents').hide();
        $('#requestActions').hide();
        $('#myReviewActions').show();
        $('input[name=SkipOrderEstimate]').remove();
        $('input[name=WebRequestForm]').val('DefaultRequest');
        $('input[name=RequestType]').val('Loan');
        $('input[name=RequestType]').after('<input type="hidden" name="UserReview" value="Yes"/>');
        e.preventDefault();
    });

    $('.request-room').on('click', function (e) {
        $('.myListContents').hide();
        $('#requestActions').hide();
        $('#myRequestActions').show();
        $('input[name=WebRequestForm]').val('DefaultRequest');
        $('input[name=RequestType]').val('Loan');
        $('input[name=SkipOrderEstimate]').remove();
        e.preventDefault();
    });

    $('.request-copies').on('click', function (e) {
        $('.myListContents').hide();
        $('#requestActions').hide();
        $('#myReproductionActions').show();
        $('input[name=WebRequestForm]').val('PhotoduplicationRequest');

        $('input[name=RequestType]').val('Copy');
        $('input[name=RequestType]').after('<input type="hidden" id="skipOrder" name="SkipOrderEstimate" value="Yes"/>');
        e.preventDefault();
    });

    // Remove all items from bookbag
    $('.myListRemoveAll').on('click', function (e) {
        var myList = [];
        saveList(myList);
        updateDisplay();
        e.preventDefault();
    });

    $('#myRequestActions').hide();
    $('#myReviewActions').hide();
    $('#myReproductionActions').hide();

    // update display
    updateDisplay();

    return false;

};


// Disables inputs when checkbox is unchecked
$(function () {
    $('.requestInputs input[name="Request"]').on('click', function () {
        if ($(this).is(':checked')) {
            $(this).siblings('input').attr("disabled", false);
            var value = $(this).attr("value");
            $('input[value=' + value + "]").attr('checked', true);
            $('input[value=' + value + "]").siblings('input').attr("disabled", false);
            if (!($(this).parents('.myListContents').hasClass('dialog'))) {
                $('input[value=' + value + "]").parents('.aeon-row').removeClass('disabled');
            }
        } else {
            $(this).siblings('input').attr("disabled", true);
            var value = $(this).attr("value");
            $('input[value=' + value + "]").attr('checked', false);
            $('input[value=' + value + "]").siblings('input').attr("disabled", true);
            if (!($(this).parents('.myListContents').hasClass('dialog'))) {
                $('input[value=' + value + "]").parents('.aeon-row').addClass('disabled');
            }
        }

        var listCount = $('#listContentForm .aeon-row:not(.header-row) > .requestInputs > input[checked="checked"]').length;
        $('.listCount').html(listCount);
    });

    $('.aeon-row:not(.header-row) input[type="checkbox"]').on('click', function (e) {
        if ($(this).is(':checked')) {
            $(this).closest('.requestInputs input[type="checkbox"]').attr('checked', true);
            $(this).closest('.aeon-row').removeClass('disabled');
            $(this).siblings().attr("disabled", false);
        } else {
            $(this).closest('.requestInputs input[type="checkbox"]').attr('checked', false);
            $(this).closest('.aeon-row').addClass('disabled');
            $(this).siblings().attr("disabled", true);
        }
        var listCount = $('#listContentForm .aeon-row:not(.header-row) > .requestInputs > input[checked="checked"]').length;
        $('.listCount').html(listCount);

    });

});


//shows or hides scheduled date and user review sections
$(function () {

    function showSection(root) {
        root.show();
        root.find(':input').prop("disabled", false);
    }

    function hideSection(root) {
        root.hide();
        root.find(':input').prop("disabled", true);
    }

    function showReview() {
        $('#VisitReview').prop("checked", true);
        showSection(userReviewLabel);
        hideSection(scheduledDateLabel);
        $('#UserReview').prop("checked", true);
    }

    function showScheduled() {
        $('#VisitScheduled').prop("checked", true);
        showSection(scheduledDateLabel);
        hideSection(userReviewLabel);
        $('#UserReview').prop("checked", false);
    }

    $(document).ready(function () {
        scheduledDateLabel = $('.scheduledDate');
        userReviewLabel = $('.userReview');

        if ((scheduledDateLabel != null) && (userReviewLabel != null) && ($('#VisitScheduled') != null) && ($('#VisitReview') != null) && ($('#UserReview') != null)) {

            $('#UserReview').hide();

            $('#VisitScheduled').click(function () {
                showScheduled();
            });

            $('#VisitReview').click(function () {
                showReview();
            });

            if ($('#UserReview').prop("checked")) {
                showReview();
            } else {
                showScheduled();
            }
        }

    });
}());

$(document).on('turbolinks:load', bookbagInitializer); // Turbolinks 5
