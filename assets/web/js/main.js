// $(function () {
//   alert("qqeqqqqqqqqqq");
//   $('[data-toggle="tooltip"]').tooltip({
//     placement: 'bottom',
//     html: true
//   });
// });


var horizontal_container = document.querySelector('.book-container-horizontal');
function search(query) {
  $(".book_text").each(function () {
    var $this = $(this);
    var checkString = $this.text();
    var start = $this.text().toLowerCase().indexOf(query);
    var end = query.slice().length;
    var matchWord = checkString.substring(start, start + end);

    if (checkString.toLowerCase().match(query)) {
      $this.html(
        checkString.replace(
          matchWord,
          '<span class="mark">' + matchWord + "</span>"
        )
      );
    }
  });

}


function getOffset(el) {
  var _x = 0;
  var _y = 0;
  while (el && !isNaN(el.offsetLeft) && !isNaN(el.offsetTop)) {
    _x += el.offsetLeft - el.scrollLeft;
    _y += el.offsetTop - el.scrollTop;
    el = el.offsetParent;
  }
  return { top: _y, left: _x };
}
// $(function () {
//   alert("f")
//   $('[data-toggle="tooltip"]').tooltip({
//     placement: 'bottom',
//     html: true
//   })
// })
let custom_slider = document.getElementById("slide_se");
document.querySelectorAll(".slider111").forEach((elem) => {
  let slider = noUiSlider.create(elem, {
    start: 1,
    tooltips: true,
    connect: "lower",
    orientation: "vertical",
    range: {
      min: 1,
      max: 100,
    },
    format: wNumb({
      decimals: 0,
    }),
  });

  elem.noUiSlider.on("change", (params) => {
    currentPage = elem.noUiSlider.get() - 1;
    window.scrollTo(0, 0);
    var y =
      window.scrollY +
      document
        .getElementById("book-mark_" + currentPage)
        .getBoundingClientRect().top -
      5;
    console.log(y);
    window.scrollTo(0, y);
  });
});


// if ($('.slider111').length > 0) {
//   $('.slider111').each(function() {
//     var step;
//     if ($(this).attr('data-step')) {
//       step = parseInt($(this).attr('data-step'));
//     } else {
//       step = 10;
//     }
//     var sliderElement = $(this).attr('id');
//     var element = $('#' + sliderElement);
//     var valueMin = parseInt($(this).attr('data-value-min'));
//     var valueMax = parseInt($(this).attr('data-value-max'));

// //Get Slider old-fashioned way, since you already have its ID
//     var sss = document.getElementById(sliderElement)

//     noUiSlider.create(sss,{
//       start: [valueMin, valueMax],
//       connect: true,
//       range: {
//         'min': valueMin,
//         'max': valueMax
//       },
//       step: step
//     });

//     if (sliderElement == "price-slider")
//       sss.noUiSlider.set([null, 2000000]); //error here
//   });
// }



function highlight_search(sw, s_type) {
  alert("er");
  $(".text_style").each(function () {
    var $this = $(this);
    var checkString = $this.html();
    if (s_type == "clear") {
      $this.html(checkString.replace('<strong class="mark">' + sw + '</strong>', sw))
    } else {
      $this.html(checkString.replace(sw, '<strong class="mark">' + sw + '</strong>'))
    }

  });
}



function setupBookmarkStatus() {
  const bookmarkElements = $('.book-mark');

  bookmarkElements.each(function (index) {
    $(this).on('click', function () {
      const item = $(this);

      // Toggle 'add_fav' class
      item.toggleClass('add_fav');

      // Notify Flutter about the change
      if (window.flutter_inappwebview) {
        window.flutter_inappwebview.callHandler('bookmarkToggled', index);
      }
    });
  });
}

// Initialize the bookmark status setup
setupBookmarkStatus();





function CommentEvent() {
  var bookmark_elems = $('.comment-button');
  bookmark_elems.each(function (index) {
    $(this).click(function () {
      var item = $(this);
      if (!item.hasClass("has-comment")) {
        item.addClass("has-comment");
      }
      if (window.flutter_inappwebview) {
        window.flutter_inappwebview.callHandler('CommentEvent', index);
      }
    });
  });
}
CommentEvent();




function GET_TOP(el) {
  let elem11 = document.getElementById(el);
  let rect = elem11.getBoundingClientRect();
  return { top: rect.top, left: rect.left };
}



// function ChangeSliderPage() {
//   input = document.getElementById("slide_se");
//   $(document).on("input", "#slide_se", function () {
//     console.log($(this).val);
//     alert("aer");
//     window.scrollTo(0, 0);
//     var y = getOffset(
//       document.getElementById("book-mark_" + ($(this).val() - 1))
//     ).top;
//     window.scrollTo(0, y);
//   });
// }

// SET BOOKPAGE FONTTYPE
let p_font = $(".book-page > div");

function clear_classfont(p_font) {
  p_font.removeAttr("class");
}
$(".radio-btn").each(function (index, value) {
  $(this).click(() => {
    let p_font = $(".book-page > div");
    clear_classfont(p_font);
    switch (index) {
      case 0:
        p_font.addClass("Lotus-Light");
        break;
      case 1:
        p_font.addClass("NotoNaskhArabic");

        break;
      case 2:
        p_font.addClass("DIJALHRegular");
    }
  });
});

/*var postBoxes = document.querySelectorAll(".book-mark");
postBoxes.forEach(function (postBox) {
  postBox.addEventListener("click", function () {
    let item = document.getElementById(postBox.id);
    if (item.classList.contains("add_fav")) {
      item.classList.remove("add_fav");
    } else {
      item.classList.add("add_fav");
    }
    // console.log(id);
  });
});*/

// initAndSetupTheSliders(1);
// function initAndSetupTheSliders(Val) {
//   const inputs = [].slice.call(
//     document.querySelectorAll(".range-slider input")
//   );
//   inputs.forEach((input) => input.setAttribute("value", Val));
//   inputs.forEach((input) => app.updateSlider(input));
//   inputs.forEach((input) =>
//     input.addEventListener("input", (element) => app.updateSlider(input))
//   );
//   inputs.forEach((input) =>
//     input.addEventListener("change", (element) => app.updateSlider(input))
//   );
// };

//  SET BACK-GROUND

function clear_classbg() {
  btn_bg.removeClass("bg-active");
  btn_bg.removeClass("animate__jello");
  $(".checked").css("opacity", "0");
}

function Close_Setting() {
  $(".overlay-setting").click(function (event) {
    const btn = $(".setting-Collapse");
    if (!btn.is(event.target) && !btn.has(event.target).length) {
      $(".overlay-setting").removeClass("show_setting");
    }
  });
}

if ($("#page-input").length > 0) {
  const sliderValue = document.getElementById("page-value");
  const inputSlider = document.getElementById("page-input");
  inputSlider.oninput = () => {
    console.log(inputSlider.max);
    let value = inputSlider.value;
    sliderValue.textContent = value;

    sliderValue.style.right = 400 * (value / inputSlider.max) + "px";
    sliderValue.classList.add("show");
  };
  inputSlider.onblur = () => {
    sliderValue.classList.remove("show");
  };

  $("#page-input").on("change", function () {
    var value = document.getElementById("page-input").value;

    console.log(value);
  });
}

/////////////////// SLIder
function updateFlutterSearchPosition() {
  console.log("🔥 Calling Flutter with:", currentPageMatchIndex + 1, matchPages.length);
  window.flutter_inappwebview.callHandler(
    'onSearchPositionChanged',
    currentPageMatchIndex + 1,
    matchPages.length
  );
}
// window.flutter_inappwebview.callHandler('onSearchPositionChanged', currentPageMatchIndex + 1, matchPages.length);

function highlight_search(query, className) {
  matchPages = [];
  currentPageMatchIndex = -1;

  const regex = new RegExp(query, 'gi');
  const pages = document.querySelectorAll(".book-page-horizontal, .book-page-vertical");

  pages.forEach((page, pageIndex) => {
    const content = page.querySelector('.book_text_horizontal, .book_text_vertical');
    if (content) {
      const originalHtml = content.innerHTML;
      let matchFound = false;

      const newHtml = originalHtml.replace(regex, (match) => {
        matchFound = true;
        return `<span class="${className}">${match}</span>`;
      });

      content.innerHTML = newHtml;

      if (matchFound) {
        matchPages.push(pageIndex);
      }
    }
  });

  if (matchPages.length > 0) {
    currentPageMatchIndex = 0;
    scrollToMatchPage(matchPages[currentPageMatchIndex]);
    updateFlutterSearchPosition();
  }
}

function scrollToMatchPage(pageIndex) {
  const target = document.querySelector(`#page___${pageIndex}`);
  if (target) {
    target.scrollIntoView({ behavior: "smooth", block: "start" });
  }
}

function goToNextMatchPage() {
  if (matchPages.length === 0) return;
  currentPageMatchIndex = (currentPageMatchIndex + 1) % matchPages.length;
  scrollToMatchPage(matchPages[currentPageMatchIndex]);
  updateFlutterSearchPosition();
}

function goToPrevMatchPage() {
  if (matchPages.length === 0) return;
  currentPageMatchIndex = (currentPageMatchIndex - 1 + matchPages.length) % matchPages.length;
  scrollToMatchPage(matchPages[currentPageMatchIndex]);
  updateFlutterSearchPosition();
}



function clearHighlights(className = 'highlight') {
  const pages = document.querySelectorAll(".book-page-horizontal, .book-page-vertical");

  pages.forEach((page) => {
    const content = page.querySelector('.book_text_horizontal, .book_text_vertical');
    if (content) {
      // Replace all spans with class "highlight" with just their inner text
      content.innerHTML = content.innerHTML.replace(
        new RegExp(`<span class=["']${className}["']>(.*?)</span>`, 'gi'),
        '$1'
      );
    }
  });

  // Reset match state
  matchPages = [];
  currentPageMatchIndex = -1;
  updateFlutterSearchPosition();
}
