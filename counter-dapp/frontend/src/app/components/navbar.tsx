

import React, { useState } from 'react'
import { useAccount, useConnect, useDisconnect } from 'wagmi'

export const navbar = () => {

    const [Connected , setConnected] = useState(false);

     const account = useAccount()
     const { connectors, connect, status, error } = useConnect()
     const { disconnect } = useDisconnect()

     const handleOnClick = () => {
          if(Connected) {
            disconnect()
            setConnected(false);
          }
     }

  return (
    <div className='top-0 inset-x-0 w-screen h-20 flex justify-between items-center'>
          <div className='bg-neutral-600 rounded-2xl px-5 py-2.5'>
               <h1 className='font-bold text-xl tracking-wide'>
                Counter Mint Dapp
               </h1>
          </div>

          <div>
            <p className='flex gap-2'>
               <div className="w-4 h-4 bg-red-500 rounded-full" />
                {account.status}
            </p>
            <button
            onClick={handleOnClick}
            className='text-white px-4 py-2 rounded-2xl border border-amber-50 '>
                  Connect Wallet
            </button>
          </div>
    </div>
  )
}


const connetWallet = () =>{
    const { connectors, connect, status, error } = useConnect();

    return (

        <div className="fixed inset-0 flex items-center justify-center z-50 bg-black bg-opacity-50">
              <h1>
                Connect 
              </h1>
              <div className='flex flex-col justify-center w-full p-2 gap-2 '>
                   {
                connectors.map((connector)=>{
                   return (
                    <button 
                    key={connector.uid}
                    onClick={()=>{
                        connect({
                            connector
                        })
                    }}
                    className='max-w-full px-4 py-2 text-md fond-bold text-neutral-50'>
                      {
                        connector.name
                      }
                    </button>
                   )
                })
              }
              </div>
        </div>
    )
}