// const index = "/geniepackagemanager";
const indexlist = "/geniepackagemanager/list"
const packageManagerBaseUrl = "/geniepackagemanager/api/v1/"

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
            isUpdateDisabled: true
        }
    },
    methods: {
        addPackage() {
            // if package contains @ split it by packageName and version
            console.log(this.toAddPackage);
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
                
                repoLink = this.toAddPackage;
                repoUrl = new URL(repoLink);

                // if package name ends with '.jl' remove it
                if (this.toAddPackage.endsWith(".jl")) {
                    this.toAddPackage = this.toAddPackage.slice(0, -3)
                }

                // if toAddPackage is a github/gitlab link
                if (repoUrl.protocol == "https:" || repoUrl.protocol == "http:") {
                    urlSplit = repoUrl.split("/");
                    packageName = urlSplit[urlSplit.length-1];
                    orgName = urlSplit[urlSplit.length-2];

                    pkgSplit = packageName.split(".")
                    pkgName = pkgSplit[0];

                    axios.post(packageManagerBaseUrl+orgName+"/"+pkgName+"/add").then(response => {
                        console.log(response);
                        window.location.reload();
                    })
                } // if toAddPackage is a package name
                else {
                    if (this.dev == false) {
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
        updateToggle() {
            if (this.updateAll == true) {
                this.isUpdateDisabled = false;
            }else{
                this.isUpdateDisabled = true;
            }
        },
        updateAllPackages() {
            if (this.isUpdateDisabled == false)
                if(confirm('are you sure you want to update all packages?'))
                    if(this.updateAll == true) {
                        this.isUpdateDisabled = false;
                        axios.post(packageManagerBaseUrl+"update_all_packages").then(response => {
                            console.log(response);
                            window.location.reload();
                        })
                    }
        }
    },
    mounted() {
        axios.get(indexlist).then(response => {
            console.log(response.data)
            obj = response.data
            const sorted = Object.keys(obj)
                .sort()
                .reduce((accumulator, key) => {
                    accumulator[key] = obj[key];

                    return accumulator;
                }, {});
            this.results = sorted
        })

    }
}).mount('#app')