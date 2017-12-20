import { NavigationModule } from 'NativeModules'
import { BASE_API_DIGITAL, BASE_API_MARKETPLACE } from './api'



// export const getEnv = () => {
//     return SessionModule.getEnv()
//         .then(res => { return res })
//         .catch(err => console.log(err))
// }

// export const getBaseAPI = (env) => {
//     let data_api = {}
    
//     if (env === 'production'){
//         const data_api = {
//             digital: `${BASE_API_DIGITAL.production}`,
//             marketplace: `${BASE_API_MARKETPLACE.production}`
//         }
//         return data_api
//     } else {
//         const data_api = {
//             digital: `${BASE_API_DIGITAL.staging}`,
//             marketplace: `${BASE_API_MARKETPLACE.staging}`
//         }
//         return data_api
//     }
//   }


export const getBaseAPI = () => {
    let data_api = {}
    return NavigationModule.getFlavor()
        .then(res => {
            if (res === 'live'){
                const data_api = {
                    digital: `${BASE_API_DIGITAL.production}`,
                    marketplace: `${BASE_API_MARKETPLACE.production}`
                }
                return data_api
            } else if (res === 'staging'){
                const data_api = {
                    digital: `${BASE_API_DIGITAL.staging}`,
                    marketplace: `${BASE_API_MARKETPLACE.staging}`
                }
                return data_api
            }
        })
        .catch(err => {
            console.log(err)
        })
}
