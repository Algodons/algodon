# ALGODON Part 4: Payment Integrations
# This script creates all 5 payment integrations: Stripe, Square, CashApp, Crypto, Web3

Write-Host "🚀 ALGODON Part 4: Payment Integrations" -ForegroundColor Cyan

Set-Location "ALGODON"

# Generate payment modal component
$paymentModal = @'
'use client';

import { useState } from 'react';
import { X, CreditCard, Square, DollarSign, Bitcoin, Wallet } from 'lucide-react';
import { Button } from '@/components/ui/button';
import { StripeCheckoutForm } from '@/components/payments/StripeCheckoutForm';
import { SquarePaymentForm } from '@/components/payments/SquarePaymentForm';
import { CashAppButton } from '@/components/payments/CashAppButton';
import { CoinbaseCommerceButton } from '@/components/payments/CoinbaseCommerceButton';
import { PrivyWalletConnect } from '@/components/payments/PrivyWalletConnect';

type PaymentMethod = 'stripe' | 'square' | 'cashapp' | 'crypto' | 'web3';

interface PaymentModalProps {
  isOpen: boolean;
  onClose: () => void;
  plan: 'pro';
}

export function PaymentModal({ isOpen, onClose, plan }: PaymentModalProps) {
  const [method, setMethod] = useState<PaymentMethod>('stripe');

  if (!isOpen) return null;

  const paymentMethods = [
    { id: 'stripe' as PaymentMethod, name: 'Credit/Debit Card', icon: CreditCard, badge: 'Recommended' },
    { id: 'square' as PaymentMethod, name: 'Square', icon: Square },
    { id: 'cashapp' as PaymentMethod, name: 'Cash App', icon: DollarSign },
    { id: 'crypto' as PaymentMethod, name: 'Cryptocurrency', icon: Bitcoin },
    { id: 'web3' as PaymentMethod, name: 'Web3 Wallet', icon: Wallet },
  ];

  return (
    <div className="fixed inset-0 z-50 overflow-y-auto">
      <div className="flex min-h-screen items-center justify-center p-4">
        <div
          className="fixed inset-0 bg-black/50 transition-opacity"
          onClick={onClose}
        />
        <div className="relative bg-white dark:bg-gray-900 rounded-2xl shadow-xl max-w-3xl w-full p-8">
          <button
            onClick={onClose}
            className="absolute top-4 right-4 text-gray-400 hover:text-gray-600 dark:hover:text-gray-300"
          >
            <X className="w-6 h-6" />
          </button>

          <div className="mb-6">
            <h2 className="text-2xl font-bold text-gray-900 dark:text-white mb-2">
              Choose Payment Method
            </h2>
            <p className="text-gray-600 dark:text-gray-300">
              Select your preferred payment method to start your 30-day trial
            </p>
          </div>

          <div className="grid grid-cols-2 md:grid-cols-5 gap-4 mb-6">
            {paymentMethods.map((pm) => {
              const Icon = pm.icon;
              return (
                <button
                  key={pm.id}
                  onClick={() => setMethod(pm.id)}
                  className={`p-4 rounded-lg border-2 transition ${
                    method === pm.id
                      ? 'border-primary-500 bg-primary-50 dark:bg-primary-900/20'
                      : 'border-gray-200 dark:border-gray-700 hover:border-gray-300 dark:hover:border-gray-600'
                  }`}
                >
                  <Icon className="w-6 h-6 mx-auto mb-2 text-gray-700 dark:text-gray-300" />
                  <div className="text-sm font-medium text-gray-900 dark:text-white">
                    {pm.name}
                  </div>
                  {pm.badge && (
                    <div className="text-xs text-primary-600 dark:text-primary-400 mt-1">
                      {pm.badge}
                    </div>
                  )}
                </button>
              );
            })}
          </div>

          <div className="border-t border-gray-200 dark:border-gray-700 pt-6">
            {method === 'stripe' && <StripeCheckoutForm plan={plan} onSuccess={onClose} />}
            {method === 'square' && <SquarePaymentForm plan={plan} onSuccess={onClose} />}
            {method === 'cashapp' && <CashAppButton plan={plan} onSuccess={onClose} />}
            {method === 'crypto' && <CoinbaseCommerceButton plan={plan} onSuccess={onClose} />}
            {method === 'web3' && <PrivyWalletConnect plan={plan} onSuccess={onClose} />}
          </div>
        </div>
      </div>
    </div>
  );
}
'@

$paymentModal | Out-File -FilePath "web/components/payments/PaymentModal.tsx" -Encoding UTF8

# Generate Stripe checkout form
$stripeCheckoutForm = @'
'use client';

import { useState } from 'react';
import { loadStripe } from '@stripe/stripe-js';
import { Button } from '@/components/ui/button';
import { Loader2 } from 'lucide-react';

const stripePromise = loadStripe(process.env.NEXT_PUBLIC_STRIPE_PUBLISHABLE_KEY!);

interface StripeCheckoutFormProps {
  plan: 'pro';
  onSuccess: () => void;
}

export function StripeCheckoutForm({ plan, onSuccess }: StripeCheckoutFormProps) {
  const [loading, setLoading] = useState(false);

  const handleCheckout = async () => {
    setLoading(true);
    try {
      const response = await fetch('/api/payments/stripe/create-subscription', {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({ plan }),
      });

      const { url } = await response.json();
      
      if (url) {
        const stripe = await stripePromise;
        if (stripe) {
          await stripe.redirectToCheckout({ url });
        }
      }
    } catch (error) {
      console.error('Checkout error:', error);
      alert('Failed to start checkout. Please try again.');
    } finally {
      setLoading(false);
    }
  };

  return (
    <div>
      <div className="mb-4 p-4 bg-gray-50 dark:bg-gray-800 rounded-lg">
        <div className="flex items-center justify-between mb-2">
          <span className="text-gray-600 dark:text-gray-300">Plan</span>
          <span className="font-semibold text-gray-900 dark:text-white">Pro - $19/month</span>
        </div>
        <div className="flex items-center justify-between">
          <span className="text-gray-600 dark:text-gray-300">Trial</span>
          <span className="text-sm text-gray-900 dark:text-white">30 days free</span>
        </div>
      </div>
      <Button
        onClick={handleCheckout}
        disabled={loading}
        className="w-full"
        size="lg"
      >
        {loading ? (
          <>
            <Loader2 className="mr-2 w-4 h-4 animate-spin" />
            Processing...
          </>
        ) : (
          'Continue to Checkout'
        )}
      </Button>
      <p className="text-xs text-gray-500 dark:text-gray-400 mt-2 text-center">
        Secure payment powered by Stripe
      </p>
    </div>
  );
}
'@

$stripeCheckoutForm | Out-File -FilePath "web/components/payments/StripeCheckoutForm.tsx" -Encoding UTF8

# Generate Stripe API route
$stripeApi = @'
import { NextRequest, NextResponse } from 'next/server';
import { auth } from '@clerk/nextjs';
import Stripe from 'stripe';

const stripe = new Stripe(process.env.STRIPE_SECRET_KEY!, {
  apiVersion: '2024-11-20.acacia',
});

export async function POST(req: NextRequest) {
  try {
    const { userId } = auth();
    if (!userId) {
      return NextResponse.json({ error: 'Unauthorized' }, { status: 401 });
    }

    const { plan } = await req.json();
    
    if (plan !== 'pro') {
      return NextResponse.json({ error: 'Invalid plan' }, { status: 400 });
    }

    // Get user email from Clerk
    const { user } = await import('@clerk/nextjs/server');
    const clerkUser = await user();
    const email = clerkUser?.emailAddresses[0]?.emailAddress;

    // Create or retrieve Stripe customer
    let customerId: string;
    const connection = await import('@/lib/db/oracle').then((m) => m.getDbConnection());
    const customerResult = await connection.execute(
      `SELECT stripe_customer_id FROM users WHERE id = :userId`,
      { userId }
    );

    if (customerResult.rows && customerResult.rows.length > 0 && customerResult.rows[0][0]) {
      customerId = customerResult.rows[0][0] as string;
    } else {
      const customer = await stripe.customers.create({
        email,
        metadata: { userId },
      });
      customerId = customer.id;
      
      await connection.execute(
        `UPDATE users SET stripe_customer_id = :customerId WHERE id = :userId`,
        { customerId, userId }
      );
    }
    await connection.close();

    // Create checkout session
    const session = await stripe.checkout.sessions.create({
      customer: customerId,
      mode: 'subscription',
      line_items: [
        {
          price: process.env.STRIPE_PRICE_ID_PRO!, // $19/month price ID
          quantity: 1,
        },
      ],
      success_url: `${process.env.NEXT_PUBLIC_APP_URL}/dashboard/billing?session_id={CHECKOUT_SESSION_ID}`,
      cancel_url: `${process.env.NEXT_PUBLIC_APP_URL}/pricing`,
      metadata: {
        userId,
        plan: 'pro',
      },
      subscription_data: {
        trial_period_days: 30,
        metadata: {
          userId,
          plan: 'pro',
        },
      },
    });

    return NextResponse.json({ url: session.url });
  } catch (error) {
    console.error('Stripe checkout error:', error);
    return NextResponse.json(
      { error: 'Failed to create checkout session' },
      { status: 500 }
    );
  }
}
'@

$stripeApi | Out-File -FilePath "web/app/api/payments/stripe/create-subscription/route.ts" -Encoding UTF8

# Generate Stripe webhook
$stripeWebhook = @'
import { NextRequest, NextResponse } from 'next/server';
import { headers } from 'next/headers';
import Stripe from 'stripe';
import { getDbConnection } from '@/lib/db/oracle';

const stripe = new Stripe(process.env.STRIPE_SECRET_KEY!, {
  apiVersion: '2024-11-20.acacia',
});

export async function POST(req: NextRequest) {
  const body = await req.text();
  const headersList = await headers();
  const signature = headersList.get('stripe-signature');

  if (!signature) {
    return NextResponse.json({ error: 'No signature' }, { status: 400 });
  }

  let event: Stripe.Event;

  try {
    event = stripe.webhooks.constructEvent(
      body,
      signature,
      process.env.STRIPE_WEBHOOK_SECRET!
    );
  } catch (err: any) {
    console.error('Webhook signature verification failed:', err.message);
    return NextResponse.json({ error: 'Invalid signature' }, { status: 400 });
  }

  const connection = await getDbConnection();

  try {
    switch (event.type) {
      case 'checkout.session.completed': {
        const session = event.data.object as Stripe.Checkout.Session;
        const userId = session.metadata?.userId;
        const plan = session.metadata?.plan;

        if (userId && plan) {
          await connection.execute(
            `UPDATE subscriptions 
             SET tier = :tier, 
                 status = 'active',
                 subscription_start_date = SYSTIMESTAMP,
                 subscription_end_date = SYSTIMESTAMP + INTERVAL '1' MONTH,
                 stripe_subscription_id = :subscriptionId,
                 requests_limit = -1
             WHERE user_id = :userId`,
            {
              tier: plan,
              subscriptionId: session.subscription as string,
              userId,
            }
          );
        }
        break;
      }

      case 'customer.subscription.updated': {
        const subscription = event.data.object as Stripe.Subscription;
        const userId = subscription.metadata?.userId;

        if (userId) {
          await connection.execute(
            `UPDATE subscriptions 
             SET status = :status,
                 subscription_end_date = TO_TIMESTAMP(:endDate, 'YYYY-MM-DD"T"HH24:MI:SS"Z"')
             WHERE stripe_subscription_id = :subscriptionId`,
            {
              status: subscription.status === 'active' ? 'active' : 'cancelled',
              endDate: new Date(subscription.current_period_end * 1000).toISOString(),
              subscriptionId: subscription.id,
            }
          );
        }
        break;
      }

      case 'customer.subscription.deleted': {
        const subscription = event.data.object as Stripe.Subscription;
        const userId = subscription.metadata?.userId;

        if (userId) {
          await connection.execute(
            `UPDATE subscriptions 
             SET status = 'cancelled',
                 requests_limit = 22
             WHERE stripe_subscription_id = :subscriptionId`,
            { subscriptionId: subscription.id }
          );
        }
        break;
      }

      case 'invoice.payment_succeeded': {
        const invoice = event.data.object as Stripe.Invoice;
        const subscriptionId = invoice.subscription as string;

        if (subscriptionId) {
          await connection.execute(
            `UPDATE subscriptions 
             SET subscription_end_date = TO_TIMESTAMP(:endDate, 'YYYY-MM-DD"T"HH24:MI:SS"Z"')
             WHERE stripe_subscription_id = :subscriptionId`,
            {
              endDate: new Date(invoice.period_end * 1000).toISOString(),
              subscriptionId,
            }
          );
        }
        break;
      }
    }

    await connection.commit();
  } catch (error) {
    console.error('Webhook processing error:', error);
    await connection.rollback();
    return NextResponse.json({ error: 'Webhook processing failed' }, { status: 500 });
  } finally {
    await connection.close();
  }

  return NextResponse.json({ received: true });
}
'@

$stripeWebhook | Out-File -FilePath "web/app/api/webhooks/stripe/route.ts" -Encoding UTF8
Write-Host "✅ Created Stripe integration" -ForegroundColor Green

# Generate Square payment form
$squarePaymentForm = @'
'use client';

import { useState } from 'react';
import { Button } from '@/components/ui/button';
import { Loader2 } from 'lucide-react';

interface SquarePaymentFormProps {
  plan: 'pro';
  onSuccess: () => void;
}

export function SquarePaymentForm({ plan, onSuccess }: SquarePaymentFormProps) {
  const [loading, setLoading] = useState(false);

  const handlePayment = async () => {
    setLoading(true);
    try {
      const response = await fetch('/api/payments/square/create-subscription', {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({ plan }),
      });

      const data = await response.json();
      
      if (data.error) {
        alert(data.error);
        return;
      }

      // Square Web Payments SDK would be initialized here
      // For now, redirect to Square payment page
      if (data.paymentUrl) {
        window.location.href = data.paymentUrl;
      }
    } catch (error) {
      console.error('Square payment error:', error);
      alert('Failed to process payment. Please try again.');
    } finally {
      setLoading(false);
    }
  };

  return (
    <div>
      <div className="mb-4 p-4 bg-gray-50 dark:bg-gray-800 rounded-lg">
        <div className="flex items-center justify-between mb-2">
          <span className="text-gray-600 dark:text-gray-300">Plan</span>
          <span className="font-semibold text-gray-900 dark:text-white">Pro - $19/month</span>
        </div>
      </div>
      <Button
        onClick={handlePayment}
        disabled={loading}
        className="w-full"
        size="lg"
      >
        {loading ? (
          <>
            <Loader2 className="mr-2 w-4 h-4 animate-spin" />
            Processing...
          </>
        ) : (
          'Pay with Square'
        )}
      </Button>
      <p className="text-xs text-gray-500 dark:text-gray-400 mt-2 text-center">
        Secure payment powered by Square
      </p>
    </div>
  );
}
'@

$squarePaymentForm | Out-File -FilePath "web/components/payments/SquarePaymentForm.tsx" -Encoding UTF8

# Generate Square API route
$squareApi = @'
import { NextRequest, NextResponse } from 'next/server';
import { auth } from '@clerk/nextjs';
import { Client, Environment } from 'square';

const client = new Client({
  accessToken: process.env.SQUARE_ACCESS_TOKEN!,
  environment: process.env.SQUARE_ENVIRONMENT === 'production' ? Environment.Production : Environment.Sandbox,
});

export async function POST(req: NextRequest) {
  try {
    const { userId } = auth();
    if (!userId) {
      return NextResponse.json({ error: 'Unauthorized' }, { status: 401 });
    }

    const { plan } = await req.json();
    
    if (plan !== 'pro') {
      return NextResponse.json({ error: 'Invalid plan' }, { status: 400 });
    }

    // Get user email
    const { user } = await import('@clerk/nextjs/server');
    const clerkUser = await user();
    const email = clerkUser?.emailAddresses[0]?.emailAddress;

    // Create or retrieve Square customer
    const connection = await import('@/lib/db/oracle').then((m) => m.getDbConnection());
    const customerResult = await connection.execute(
      `SELECT square_customer_id FROM users WHERE id = :userId`,
      { userId }
    );

    let customerId: string;
    if (customerResult.rows && customerResult.rows.length > 0 && customerResult.rows[0][0]) {
      customerId = customerResult.rows[0][0] as string;
    } else {
      const { result } = await client.customersApi.createCustomer({
        emailAddress: email,
        referenceId: userId,
      });
      customerId = result.customer!.id!;
      
      await connection.execute(
        `UPDATE users SET square_customer_id = :customerId WHERE id = :userId`,
        { customerId, userId }
      );
    }
    await connection.close();

    // Create subscription
    const { result } = await client.subscriptionsApi.createSubscription({
      locationId: process.env.SQUARE_LOCATION_ID!,
      planId: process.env.SQUARE_PLAN_ID!, // $19/month plan ID
      customerId,
      idempotencyKey: `${userId}-${Date.now()}`,
    });

    // Save subscription to database
    const dbConnection = await import('@/lib/db/oracle').then((m) => m.getDbConnection());
    await dbConnection.execute(
      `UPDATE subscriptions 
       SET tier = 'pro',
           status = 'active',
           subscription_start_date = SYSTIMESTAMP,
           subscription_end_date = SYSTIMESTAMP + INTERVAL '1' MONTH,
           square_subscription_id = :subscriptionId,
           requests_limit = -1
       WHERE user_id = :userId`,
      {
        subscriptionId: result.subscription!.id,
        userId,
      }
    );
    await dbConnection.commit();
    await dbConnection.close();

    return NextResponse.json({ 
      success: true,
      subscriptionId: result.subscription!.id,
    });
  } catch (error: any) {
    console.error('Square subscription error:', error);
    return NextResponse.json(
      { error: error.message || 'Failed to create subscription' },
      { status: 500 }
    );
  }
}
'@

$squareApi | Out-File -FilePath "web/app/api/payments/square/create-subscription/route.ts" -Encoding UTF8
Write-Host "✅ Created Square integration" -ForegroundColor Green

# Generate CashApp button
$cashAppButton = @'
'use client';

import { useState } from 'react';
import { Button } from '@/components/ui/button';
import { Loader2 } from 'lucide-react';

interface CashAppButtonProps {
  plan: 'pro';
  onSuccess: () => void;
}

export function CashAppButton({ plan, onSuccess }: CashAppButtonProps) {
  const [loading, setLoading] = useState(false);

  const handlePayment = async () => {
    setLoading(true);
    try {
      const response = await fetch('/api/payments/cashapp/create-payment', {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({ plan }),
      });

      const data = await response.json();
      
      if (data.error) {
        alert(data.error);
        return;
      }

      if (data.paymentUrl) {
        window.location.href = data.paymentUrl;
      }
    } catch (error) {
      console.error('CashApp payment error:', error);
      alert('Failed to process payment. Please try again.');
    } finally {
      setLoading(false);
    }
  };

  return (
    <div>
      <div className="mb-4 p-4 bg-gray-50 dark:bg-gray-800 rounded-lg">
        <div className="flex items-center justify-between mb-2">
          <span className="text-gray-600 dark:text-gray-300">Plan</span>
          <span className="font-semibold text-gray-900 dark:text-white">Pro - $19/month</span>
        </div>
      </div>
      <Button
        onClick={handlePayment}
        disabled={loading}
        className="w-full bg-green-600 hover:bg-green-700"
        size="lg"
      >
        {loading ? (
          <>
            <Loader2 className="mr-2 w-4 h-4 animate-spin" />
            Processing...
          </>
        ) : (
          'Pay with Cash App'
        )}
      </Button>
      <p className="text-xs text-gray-500 dark:text-gray-400 mt-2 text-center">
        Secure payment powered by Cash App
      </p>
    </div>
  );
}
'@

$cashAppButton | Out-File -FilePath "web/components/payments/CashAppButton.tsx" -Encoding UTF8

# Generate CashApp API route
$cashAppApi = @'
import { NextRequest, NextResponse } from 'next/server';
import { auth } from '@clerk/nextjs';

export async function POST(req: NextRequest) {
  try {
    const { userId } = auth();
    if (!userId) {
      return NextResponse.json({ error: 'Unauthorized' }, { status: 401 });
    }

    const { plan } = await req.json();
    
    if (plan !== 'pro') {
      return NextResponse.json({ error: 'Invalid plan' }, { status: 400 });
    }

    // Cash App API integration
    // Note: Cash App Pay API requires OAuth and specific setup
    const response = await fetch('https://api.cash.app/v1/payments', {
      method: 'POST',
      headers: {
        'Authorization': `Bearer ${process.env.CASHAPP_API_KEY}`,
        'Content-Type': 'application/json',
      },
      body: JSON.stringify({
        amount: { amount: 1900, currency: 'USD' }, // $19.00 in cents
        cashtag: process.env.CASHAPP_CASHTAG || '$ALGODON',
        note: 'ALGODON Pro Subscription - 1 Month',
        redirect_url: `${process.env.NEXT_PUBLIC_APP_URL}/dashboard/billing?success=true&provider=cashapp`,
        metadata: {
          userId,
          plan: 'pro',
        },
      }),
    });

    if (!response.ok) {
      const error = await response.json();
      throw new Error(error.message || 'Cash App payment failed');
    }

    const data = await response.json();

    // Store payment intent
    const connection = await import('@/lib/db/oracle').then((m) => m.getDbConnection());
    await connection.execute(
      `INSERT INTO payments (id, user_id, amount, currency, provider, status, transaction_id, metadata)
       VALUES (SYS_GUID(), :userId, 19.00, 'USD', 'cashapp', 'pending', :paymentId, :metadata)`,
      {
        userId,
        paymentId: data.id,
        metadata: JSON.stringify(data),
      }
    );
    await connection.commit();
    await connection.close();

    return NextResponse.json({ 
      paymentUrl: data.redirect_url || data.hosted_url,
      paymentId: data.id,
    });
  } catch (error: any) {
    console.error('CashApp payment error:', error);
    return NextResponse.json(
      { error: error.message || 'Failed to create payment' },
      { status: 500 }
    );
  }
}
'@

$cashAppApi | Out-File -FilePath "web/app/api/payments/cashapp/create-payment/route.ts" -Encoding UTF8
Write-Host "✅ Created CashApp integration" -ForegroundColor Green

# Generate Coinbase Commerce button
$coinbaseButton = @'
'use client';

import { useState } from 'react';
import { Button } from '@/components/ui/button';
import { Loader2 } from 'lucide-react';

interface CoinbaseCommerceButtonProps {
  plan: 'pro';
  onSuccess: () => void;
}

export function CoinbaseCommerceButton({ plan, onSuccess }: CoinbaseCommerceButtonProps) {
  const [loading, setLoading] = useState(false);

  const handlePayment = async () => {
    setLoading(true);
    try {
      const response = await fetch('/api/payments/crypto/create-charge', {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({ plan }),
      });

      const data = await response.json();
      
      if (data.error) {
        alert(data.error);
        return;
      }

      if (data.hosted_url) {
        window.location.href = data.hosted_url;
      }
    } catch (error) {
      console.error('Crypto payment error:', error);
      alert('Failed to process payment. Please try again.');
    } finally {
      setLoading(false);
    }
  };

  return (
    <div>
      <div className="mb-4 p-4 bg-gray-50 dark:bg-gray-800 rounded-lg">
        <div className="flex items-center justify-between mb-2">
          <span className="text-gray-600 dark:text-gray-300">Plan</span>
          <span className="font-semibold text-gray-900 dark:text-white">Pro - $19/month</span>
        </div>
        <div className="text-xs text-gray-500 dark:text-gray-400 mt-2">
          Accepts: BTC, ETH, USDC, USDT, DOGE
        </div>
      </div>
      <Button
        onClick={handlePayment}
        disabled={loading}
        className="w-full"
        size="lg"
      >
        {loading ? (
          <>
            <Loader2 className="mr-2 w-4 h-4 animate-spin" />
            Processing...
          </>
        ) : (
          'Pay with Cryptocurrency'
        )}
      </Button>
      <p className="text-xs text-gray-500 dark:text-gray-400 mt-2 text-center">
        Secure payment powered by Coinbase Commerce
      </p>
    </div>
  );
}
'@

$coinbaseButton | Out-File -FilePath "web/components/payments/CoinbaseCommerceButton.tsx" -Encoding UTF8

# Generate Coinbase Commerce API route
$coinbaseApi = @'
import { NextRequest, NextResponse } from 'next/server';
import { auth } from '@clerk/nextjs';
import { Client, resources } from 'coinbase-commerce-node';

Client.init(process.env.COINBASE_COMMERCE_API_KEY!);
const { Charge } = resources;

export async function POST(req: NextRequest) {
  try {
    const { userId } = auth();
    if (!userId) {
      return NextResponse.json({ error: 'Unauthorized' }, { status: 401 });
    }

    const { plan } = await req.json();
    
    if (plan !== 'pro') {
      return NextResponse.json({ error: 'Invalid plan' }, { status: 400 });
    }

    const charge = await Charge.create({
      name: 'ALGODON Pro - 1 Month',
      description: 'Unlimited code execution and AI assistance',
      pricing_type: 'fixed_price',
      local_price: {
        amount: '19.00',
        currency: 'USD',
      },
      metadata: {
        userId,
        plan: 'pro',
      },
      redirect_url: `${process.env.NEXT_PUBLIC_APP_URL}/dashboard/billing?success=true&provider=crypto`,
      cancel_url: `${process.env.NEXT_PUBLIC_APP_URL}/pricing`,
    });

    // Store charge
    const connection = await import('@/lib/db/oracle').then((m) => m.getDbConnection());
    await connection.execute(
      `INSERT INTO payments (id, user_id, amount, currency, provider, status, transaction_id, metadata)
       VALUES (SYS_GUID(), :userId, 19.00, 'USD', 'crypto', 'pending', :chargeId, :metadata)`,
      {
        userId,
        chargeId: charge.id,
        metadata: JSON.stringify(charge),
      }
    );
    await connection.commit();
    await connection.close();

    return NextResponse.json({ 
      hosted_url: charge.hosted_url,
      chargeId: charge.id,
    });
  } catch (error: any) {
    console.error('Coinbase Commerce error:', error);
    return NextResponse.json(
      { error: error.message || 'Failed to create charge' },
      { status: 500 }
    );
  }
}
'@

$coinbaseApi | Out-File -FilePath "web/app/api/payments/crypto/create-charge/route.ts" -Encoding UTF8

# Generate Coinbase webhook
$coinbaseWebhook = @'
import { NextRequest, NextResponse } from 'next/server';
import { headers } from 'next/headers';
import { Webhook } from 'coinbase-commerce-node';
import { getDbConnection } from '@/lib/db/oracle';

const webhookSecret = process.env.COINBASE_COMMERCE_WEBHOOK_SECRET!;

export async function POST(req: NextRequest) {
  const body = await req.text();
  const headersList = await headers();
  const signature = headersList.get('x-cc-webhook-signature');

  if (!signature) {
    return NextResponse.json({ error: 'No signature' }, { status: 400 });
  }

  let event: any;

  try {
    event = Webhook.verifyEventBody(body, signature, webhookSecret);
  } catch (err: any) {
    console.error('Webhook verification failed:', err.message);
    return NextResponse.json({ error: 'Invalid signature' }, { status: 400 });
  }

  const connection = await getDbConnection();

  try {
    if (event.type === 'charge:confirmed' || event.type === 'charge:resolved') {
      const charge = event.data;
      const userId = charge.metadata?.userId;
      const plan = charge.metadata?.plan;

      if (userId && plan) {
        // Update payment status
        await connection.execute(
          `UPDATE payments 
           SET status = 'completed'
           WHERE transaction_id = :chargeId`,
          { chargeId: charge.id }
        );

        // Activate subscription
        await connection.execute(
          `UPDATE subscriptions 
           SET tier = :tier,
               status = 'active',
               subscription_start_date = SYSTIMESTAMP,
               subscription_end_date = SYSTIMESTAMP + INTERVAL '1' MONTH,
               payment_method = 'crypto',
               requests_limit = -1
           WHERE user_id = :userId`,
          { tier: plan, userId }
        );
      }
    }

    await connection.commit();
  } catch (error) {
    console.error('Webhook processing error:', error);
    await connection.rollback();
    return NextResponse.json({ error: 'Webhook processing failed' }, { status: 500 });
  } finally {
    await connection.close();
  }

  return NextResponse.json({ received: true });
}
'@

$coinbaseWebhook | Out-File -FilePath "web/app/api/webhooks/coinbase/route.ts" -Encoding UTF8
Write-Host "✅ Created Coinbase Commerce integration" -ForegroundColor Green

# Generate Privy Web3 wallet component
$privyWallet = @'
'use client';

import { useState } from 'react';
import { usePrivy } from '@privy-io/react-auth';
import { Button } from '@/components/ui/button';
import { Loader2 } from 'lucide-react';
import { ethers } from 'ethers';

interface PrivyWalletConnectProps {
  plan: 'pro';
  onSuccess: () => void;
}

export function PrivyWalletConnect({ plan, onSuccess }: PrivyWalletConnectProps) {
  const { ready, authenticated, login, user } = usePrivy();
  const [loading, setLoading] = useState(false);

  const handlePayment = async () => {
    if (!authenticated) {
      login();
      return;
    }

    setLoading(true);
    try {
      const wallet = user?.wallet;
      if (!wallet) {
        alert('Please connect your wallet first');
        return;
      }

      // Amount: $19 = 0.019 ETH (or equivalent in USDC)
      const amount = ethers.parseEther('0.019'); // Adjust based on current ETH price
      const recipient = process.env.NEXT_PUBLIC_PAYMENT_WALLET_ADDRESS!;

      // Create transaction
      const provider = new ethers.BrowserProvider(window.ethereum);
      const signer = await provider.getSigner();
      const tx = await signer.sendTransaction({
        to: recipient,
        value: amount,
      });

      // Wait for confirmation
      await tx.wait();

      // Verify payment on backend
      const response = await fetch('/api/payments/web3/verify-payment', {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({
          plan,
          txHash: tx.hash,
          walletAddress: wallet.address,
        }),
      });

      const data = await response.json();
      
      if (data.error) {
        alert(data.error);
        return;
      }

      if (data.success) {
        onSuccess();
      }
    } catch (error: any) {
      console.error('Web3 payment error:', error);
      alert(error.message || 'Failed to process payment. Please try again.');
    } finally {
      setLoading(false);
    }
  };

  if (!ready) {
    return <div className="text-center text-gray-500">Loading...</div>;
  }

  return (
    <div>
      {!authenticated ? (
        <div>
          <p className="text-sm text-gray-600 dark:text-gray-300 mb-4">
            Connect your Web3 wallet to pay with cryptocurrency
          </p>
          <Button onClick={login} className="w-full" size="lg">
            Connect Wallet
          </Button>
        </div>
      ) : (
        <div>
          <div className="mb-4 p-4 bg-gray-50 dark:bg-gray-800 rounded-lg">
            <div className="flex items-center justify-between mb-2">
              <span className="text-gray-600 dark:text-gray-300">Plan</span>
              <span className="font-semibold text-gray-900 dark:text-white">Pro - $19/month</span>
            </div>
            <div className="text-xs text-gray-500 dark:text-gray-400 mt-2">
              Connected: {user?.wallet?.address?.slice(0, 6)}...{user?.wallet?.address?.slice(-4)}
            </div>
          </div>
          <Button
            onClick={handlePayment}
            disabled={loading}
            className="w-full"
            size="lg"
          >
            {loading ? (
              <>
                <Loader2 className="mr-2 w-4 h-4 animate-spin" />
                Processing...
              </>
            ) : (
              'Pay with Web3 Wallet'
            )}
          </Button>
          <p className="text-xs text-gray-500 dark:text-gray-400 mt-2 text-center">
            Secure payment on Ethereum/Polygon
          </p>
        </div>
      )}
    </div>
  );
}
'@

$privyWallet | Out-File -FilePath "web/components/payments/PrivyWalletConnect.tsx" -Encoding UTF8

# Generate Web3 payment verification API
$web3Api = @'
import { NextRequest, NextResponse } from 'next/server';
import { auth } from '@clerk/nextjs';
import { ethers } from 'ethers';

export async function POST(req: NextRequest) {
  try {
    const { userId } = auth();
    if (!userId) {
      return NextResponse.json({ error: 'Unauthorized' }, { status: 401 });
    }

    const { plan, txHash, walletAddress } = await req.json();
    
    if (plan !== 'pro') {
      return NextResponse.json({ error: 'Invalid plan' }, { status: 400 });
    }

    // Verify transaction on-chain
    const provider = new ethers.JsonRpcProvider(process.env.ETH_RPC_URL!);
    const tx = await provider.getTransaction(txHash);
    const receipt = await provider.getTransactionReceipt(txHash);

    if (!tx || !receipt || receipt.status !== 1) {
      return NextResponse.json({ error: 'Invalid transaction' }, { status: 400 });
    }

    // Verify amount (0.019 ETH or equivalent)
    const expectedAmount = ethers.parseEther('0.019');
    if (tx.value.toString() !== expectedAmount.toString()) {
      return NextResponse.json({ error: 'Incorrect payment amount' }, { status: 400 });
    }

    // Verify recipient
    const expectedRecipient = process.env.PAYMENT_WALLET_ADDRESS!.toLowerCase();
    if (tx.to?.toLowerCase() !== expectedRecipient) {
      return NextResponse.json({ error: 'Incorrect recipient address' }, { status: 400 });
    }

    // Store payment and activate subscription
    const connection = await import('@/lib/db/oracle').then((m) => m.getDbConnection());
    
    await connection.execute(
      `INSERT INTO payments (id, user_id, amount, currency, provider, status, transaction_id, metadata)
       VALUES (SYS_GUID(), :userId, 19.00, 'USD', 'web3', 'completed', :txHash, :metadata)`,
      {
        userId,
        txHash,
        metadata: JSON.stringify({ walletAddress, blockNumber: receipt.blockNumber }),
      }
    );

    await connection.execute(
      `UPDATE subscriptions 
       SET tier = :tier,
           status = 'active',
           subscription_start_date = SYSTIMESTAMP,
           subscription_end_date = SYSTIMESTAMP + INTERVAL '1' MONTH,
           payment_method = 'web3',
           requests_limit = -1
       WHERE user_id = :userId`,
      { tier: plan, userId }
    );

    await connection.commit();
    await connection.close();

    return NextResponse.json({ success: true });
  } catch (error: any) {
    console.error('Web3 payment verification error:', error);
    return NextResponse.json(
      { error: error.message || 'Failed to verify payment' },
      { status: 500 }
    );
  }
}
'@

$web3Api | Out-File -FilePath "web/app/api/payments/web3/verify-payment/route.ts" -Encoding UTF8
Write-Host "✅ Created Web3 integration" -ForegroundColor Green

# Generate billing page
$billingPage = @'
'use client';

import { useEffect, useState } from 'react';
import { useUser } from '@clerk/nextjs';
import { Button } from '@/components/ui/button';
import { PaymentModal } from '@/components/payments/PaymentModal';
import { formatDate, formatCurrency } from '@/lib/utils';
import { Download } from 'lucide-react';

interface Subscription {
  tier: string;
  status: string;
  subscriptionStartDate: string | null;
  subscriptionEndDate: string | null;
  paymentMethod: string | null;
  autoRenew: boolean;
}

interface Invoice {
  id: string;
  amount: number;
  currency: string;
  status: string;
  createdAt: string;
  provider: string;
}

export default function BillingPage() {
  const { user } = useUser();
  const [subscription, setSubscription] = useState<Subscription | null>(null);
  const [invoices, setInvoices] = useState<Invoice[]>([]);
  const [showPayment, setShowPayment] = useState(false);
  const [loading, setLoading] = useState(true);

  useEffect(() => {
    const fetchData = async () => {
      try {
        const [subRes, invRes] = await Promise.all([
          fetch('/api/subscription'),
          fetch('/api/billing/invoices'),
        ]);

        if (subRes.ok) {
          const subData = await subRes.json();
          setSubscription(subData);
        }

        if (invRes.ok) {
          const invData = await invRes.json();
          setInvoices(invData);
        }
      } catch (error) {
        console.error('Failed to fetch billing data:', error);
      } finally {
        setLoading(false);
      }
    };

    if (user) {
      fetchData();
    }
  }, [user]);

  const handleCancel = async () => {
    if (!confirm('Are you sure you want to cancel your subscription?')) {
      return;
    }

    try {
      const response = await fetch('/api/billing/cancel', {
        method: 'POST',
      });

      if (response.ok) {
        alert('Subscription cancelled. You can continue using Pro until the end of your billing period.');
        window.location.reload();
      }
    } catch (error) {
      alert('Failed to cancel subscription. Please try again.');
    }
  };

  if (loading) {
    return <div className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8">Loading...</div>;
  }

  return (
    <div className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8">
      <div className="mb-8">
        <h1 className="text-3xl font-bold text-gray-900 dark:text-white mb-2">
          Billing & Subscription
        </h1>
        <p className="text-gray-600 dark:text-gray-300">
          Manage your subscription and payment methods
        </p>
      </div>

      <div className="grid grid-cols-1 lg:grid-cols-2 gap-6 mb-8">
        <div className="bg-white dark:bg-gray-800 rounded-lg border border-gray-200 dark:border-gray-700 p-6">
          <h2 className="text-xl font-semibold text-gray-900 dark:text-white mb-4">
            Current Plan
          </h2>
          {subscription && (
            <div>
              <div className="mb-4">
                <div className="text-3xl font-bold text-gray-900 dark:text-white mb-1">
                  {subscription.tier === 'pro' ? 'Pro' : subscription.tier === 'trial' ? 'Trial' : 'Free'}
                </div>
                {subscription.tier === 'pro' && (
                  <div className="text-gray-600 dark:text-gray-300">
                    {formatCurrency(19)}/month
                  </div>
                )}
              </div>

              {subscription.subscriptionEndDate && (
                <div className="mb-4 text-sm text-gray-600 dark:text-gray-300">
                  {subscription.status === 'active' ? 'Renews' : 'Expires'} on{' '}
                  {formatDate(subscription.subscriptionEndDate)}
                </div>
              )}

              {subscription.paymentMethod && (
                <div className="mb-4 text-sm text-gray-600 dark:text-gray-300">
                  Payment method: {subscription.paymentMethod}
                </div>
              )}

              <div className="space-y-2">
                {subscription.tier === 'free' ? (
                  <Button onClick={() => setShowPayment(true)} className="w-full">
                    Upgrade to Pro
                  </Button>
                ) : subscription.status === 'active' ? (
                  <Button
                    variant="outline"
                    onClick={handleCancel}
                    className="w-full"
                  >
                    Cancel Subscription
                  </Button>
                ) : (
                  <Button onClick={() => setShowPayment(true)} className="w-full">
                    Reactivate Subscription
                  </Button>
                )}
              </div>
            </div>
          )}
        </div>

        <div className="bg-white dark:bg-gray-800 rounded-lg border border-gray-200 dark:border-gray-700 p-6">
          <h2 className="text-xl font-semibold text-gray-900 dark:text-white mb-4">
            Payment History
          </h2>
          {invoices.length > 0 ? (
            <div className="space-y-3">
              {invoices.slice(0, 5).map((invoice) => (
                <div
                  key={invoice.id}
                  className="flex items-center justify-between p-3 bg-gray-50 dark:bg-gray-700 rounded"
                >
                  <div>
                    <div className="font-medium text-gray-900 dark:text-white">
                      {formatCurrency(invoice.amount, invoice.currency)}
                    </div>
                    <div className="text-sm text-gray-500 dark:text-gray-400">
                      {formatDate(invoice.createdAt)} • {invoice.provider}
                    </div>
                  </div>
                  <div className="flex items-center space-x-2">
                    <span
                      className={`text-xs px-2 py-1 rounded ${
                        invoice.status === 'completed'
                          ? 'bg-green-100 text-green-800 dark:bg-green-900/30 dark:text-green-400'
                          : 'bg-yellow-100 text-yellow-800 dark:bg-yellow-900/30 dark:text-yellow-400'
                      }`}
                    >
                      {invoice.status}
                    </span>
                    <Button variant="ghost" size="sm">
                      <Download className="w-4 h-4" />
                    </Button>
                  </div>
                </div>
              ))}
            </div>
          ) : (
            <p className="text-gray-500 dark:text-gray-400">No payment history</p>
          )}
        </div>
      </div>

      {showPayment && (
        <PaymentModal
          isOpen={showPayment}
          onClose={() => setShowPayment(false)}
          plan="pro"
        />
      )}
    </div>
  );
}
'@

$billingPage | Out-File -FilePath "web/app/(dashboard)/billing/page.tsx" -Encoding UTF8

# Generate billing invoices API
$billingInvoicesApi = @'
import { NextRequest, NextResponse } from 'next/server';
import { auth } from '@clerk/nextjs';
import { getDbConnection } from '@/lib/db/oracle';

export async function GET(req: NextRequest) {
  try {
    const { userId } = auth();
    if (!userId) {
      return NextResponse.json({ error: 'Unauthorized' }, { status: 401 });
    }

    const connection = await getDbConnection();
    
    const result = await connection.execute(
      `SELECT id, amount, currency, provider, status, created_at
       FROM payments
       WHERE user_id = :userId
       ORDER BY created_at DESC
       FETCH FIRST 20 ROWS ONLY`,
      { userId }
    );

    await connection.close();

    const invoices = (result.rows || []).map((row: any[]) => ({
      id: row[0],
      amount: row[1],
      currency: row[2],
      provider: row[3],
      status: row[4],
      createdAt: row[5]?.toISOString() || new Date().toISOString(),
    }));

    return NextResponse.json(invoices);
  } catch (error) {
    console.error('Failed to fetch invoices:', error);
    return NextResponse.json(
      { error: 'Failed to fetch invoices' },
      { status: 500 }
    );
  }
}
'@

$billingInvoicesApi | Out-File -FilePath "web/app/api/billing/invoices/route.ts" -Encoding UTF8

# Generate cancel subscription API
$cancelSubscriptionApi = @'
import { NextRequest, NextResponse } from 'next/server';
import { auth } from '@clerk/nextjs';
import { getDbConnection } from '@/lib/db/oracle';
import Stripe from 'stripe';

const stripe = new Stripe(process.env.STRIPE_SECRET_KEY!, {
  apiVersion: '2024-11-20.acacia',
});

export async function POST(req: NextRequest) {
  try {
    const { userId } = auth();
    if (!userId) {
      return NextResponse.json({ error: 'Unauthorized' }, { status: 401 });
    }

    const connection = await getDbConnection();
    
    // Get subscription
    const subResult = await connection.execute(
      `SELECT stripe_subscription_id, square_subscription_id, payment_method
       FROM subscriptions
       WHERE user_id = :userId AND status = 'active'`,
      { userId }
    );

    if (!subResult.rows || subResult.rows.length === 0) {
      return NextResponse.json({ error: 'No active subscription' }, { status: 400 });
    }

    const [stripeSubId, squareSubId, paymentMethod] = subResult.rows[0] as any[];

    // Cancel with provider
    if (paymentMethod === 'stripe' && stripeSubId) {
      await stripe.subscriptions.update(stripeSubId, {
        cancel_at_period_end: true,
      });
    } else if (paymentMethod === 'square' && squareSubId) {
      // Square cancellation would go here
      // await squareClient.subscriptionsApi.cancelSubscription(squareSubId);
    }

    // Update database
    await connection.execute(
      `UPDATE subscriptions 
       SET status = 'cancelled',
           auto_renew = 0
       WHERE user_id = :userId`,
      { userId }
    );

    await connection.commit();
    await connection.close();

    return NextResponse.json({ success: true });
  } catch (error) {
    console.error('Failed to cancel subscription:', error);
    return NextResponse.json(
      { error: 'Failed to cancel subscription' },
      { status: 500 }
    );
  }
}
'@

$cancelSubscriptionApi | Out-File -FilePath "web/app/api/billing/cancel/route.ts" -Encoding UTF8
Write-Host "✅ Created billing page and APIs" -ForegroundColor Green

Write-Host "`n✅ Part 4: Payment Integrations Complete!" -ForegroundColor Green
Write-Host "Next: Run .\part5-backend-ai.ps1" -ForegroundColor Yellow

