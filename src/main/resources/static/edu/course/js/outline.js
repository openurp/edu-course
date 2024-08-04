const SafeRenderer = {
  forHtml: (templateData, ...values) => {
    let result = templateData[0];
    for (let i = 0; i < values.length; i++) {
      result += String(values[i])
        .replace(/&/g, '&amp;')
        .replace(/</g, '&lt;')
        .replace(/>/g, '&gt;')
        .replace(/"/g, '&quot;')
        .replace(/'/g, '&apos;');
      result += templateData[i + 1];
    }
    return result;
  }
}
const initCatalogs = () => {
  const $catalogs = [];
  for (let anchor of $('.q-heading-anchor')) {
    const $anchor = $(anchor);
    const anchorName = $anchor.attr('name');
    const headingName = $anchor.parent().text();
    const headingLevel = $anchor.parent()[0].tagName.toLowerCase();
      $catalogs.push(SafeRenderer.forHtml `
        <div class="catalog catalog-${headingLevel}" name="${anchorName}">
          <a href="#${anchorName}">${headingName}</a>
        </div>
      `);
  }
  $('#catalogs .page-body-module-content').append($catalogs);

  const catalogTrack = () => {
    let $currentAnchor = $('h1>.q-heading-anchor');
    for (let anchor of $('.q-heading-anchor')) {
      const $anchor = $(anchor);
      if ($anchor.offset().top - $(document).scrollTop() > 20) {
        break;
      }
      $currentAnchor = $anchor;
    }

    const anchorName = $currentAnchor.attr('name');
    const $catalog = $(`.catalog[name="${anchorName}"]`);
    if (!$catalog.hasClass('catalog-active')) {
      $('.catalog-active').removeClass('catalog-active');
      $catalog.addClass('catalog-active');
    }

    if ($catalog.length > 0) {
      $('#catalogs .page-body-module-content').scrollTop($catalog[0].offsetTop - 100);
    } else {
      $('#catalogs .page-body-module-content').scrollTop(0);
    }
  };
  $(window).scroll(catalogTrack);

  const catalogsAdjust = () => {
    const headerHeight = $('body>header').outerHeight();
    const top = headerHeight +
      parseFloat($('#catalogs').css('margin-top')) +
      parseFloat($('#page-body').css('padding-top'));
    const bottom = 0 +
      parseFloat($('#catalogs').css('margin-bottom')) +
      parseFloat($('#page-body').css('padding-bottom'));
    $('#catalogs').css({
      top,
      'max-height': $(window).height() - top - bottom,
    });
    $('#toolboxes').css({
      top,
      'max-height': $(window).height() - top - bottom,
    });
    catalogTrack();
  };
  $(window).resize(catalogsAdjust);
  catalogsAdjust();
};
initCatalogs();
