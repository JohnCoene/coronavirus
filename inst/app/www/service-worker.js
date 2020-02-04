if (navigator.serviceWorker) {
  navigator.serviceWorker.register('./www/sw.js', {scope: '/'}).then(function(registration) {
    console.log('ServiceWorker registration successful with scope:',  registration.scope);
  }).catch(function(error) {
    console.log('ServiceWorker registration failed:', error);
  });
}