try
    require! 'app/tools'
    loadingMessage "1/3"
    <~ getDep "css/vendor2.css"
    loadingMessage "2/3"
    <~ getDep "js/vendor2.js"
    loadingMessage "3/3"
    <~ getDep "js/app2.js"
    loadingMessage "Rendering..."
catch
    loadingError (e.stack or e)
