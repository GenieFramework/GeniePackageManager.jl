const index = "http://127.0.0.1:8000/geniepackagemanager";
const packageManagerBaseUrl = "http://127.0.0.1:8000/geniepackagemanager/api/v1/"

const {
    createApp
} = Vue

createApp({
    data() {
        return {
            results: {},
            toAddPackage: "",
            dev: false,
            updateAll: false,
        }
    },
    methods: {
        addPackage() {
            // if package contains @ split it by packageName and version
            if (this.toAddPackage.includes('@')) {
                const pkgSplit = this.toAddPackage.split("@");
                toAddPackage = pkgSplit[0];
                version = pkgSplit[1];

                axios.post(packageManagerBaseUrl+toAddPackage+"/"+version+"/add").then(response => {
                    console.log(response);
                    window.location.reload();
                })
            }
            else{
                // if package name ends with '.jl' remove it
                if (this.toAddPackage.endsWith(".jl")) {
                    this.toAddPackage = this.toAddPackage.slice(0, -3)
                }

                if (this.dev == false) {
                    console.log("installing package: " + this.toAddPackage);
                    axios.post(packageManagerBaseUrl+this.toAddPackage+"/add").then(response => {
                        console.log(response);
                        window.location.reload();
                    })
                }
                else {
                    console.log("installing package" + this.toAddPackage + "in dev mode");
                    axios.post(packageManagerBaseUrl+this.toAddPackage+"/dev").then(response => {
                        console.log(response);
                        window.location.reload();
                    })
                }
            }
            
        },
        removePackage(packageName) {
            if(confirm('are you sure you want to update ' + packageName + '?'))
                axios.post(packageManagerBaseUrl+packageName+"/remove").then(response => {
                    console.log(response);
                    window.location.reload();
                })
        },
        updatePackage(packageName) {
            if(confirm('are you sure you want to update package: ' + packageName + '?'))
                axios.post(packageManagerBaseUrl+packageName+"/update").then(response => {
                    console.log(response);
                    window.location.reload();
                })
        },
        updateAllPackages() {
            if(confirm('are you sure you want to update all packages?'))
                axios.post(packageManagerBaseUrl+"update_all_packages").then(response => {
                    console.log(response);
                    window.location.reload();
                })
        }
    },
    mounted() {
        axios.get(index).then(response => {
            console.log(response.data)
            this.results = response.data
        })

    }
}).mount('#app')